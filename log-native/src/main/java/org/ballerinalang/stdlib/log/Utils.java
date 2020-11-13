/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.ballerinalang.stdlib.log;

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.logging.util.BLogLevel;

import java.util.Map;

/**
 * Native function implementations of the log-api module.
 *
 * @since 1.1.0
 */
public class Utils extends AbstractLogFunction {

    public static void logExtern(BString logLevel, Object msg, Object logContext, Object loggerLevel) {
        BLogLevel level = BLogLevel.toBLogLevel(logLevel.toString());
        boolean logLevelEnabled;
        if (loggerLevel != null) {
            BLogLevel definedLoggerLevel = BLogLevel.toBLogLevel(loggerLevel.toString());
            logLevelEnabled = definedLoggerLevel.value() <= level.value();
        } else if (LOG_MANAGER.isModuleLogLevelEnabled()) {
            logLevelEnabled = LOG_MANAGER.getPackageLogLevel(getPackagePath()).value() <= level.value();
        } else {
            logLevelEnabled = LOG_MANAGER.getPackageLogLevel(".").value() <= level.value();
        }
        if (logLevelEnabled) {
            StringBuilder keyValues = new StringBuilder("");
            BMap<BString, Object> contextMap = (BMap<BString, Object>) logContext;
            if (contextMap != null) {
                int count = 0;
                for (Map.Entry<BString, Object> fieldEntry : contextMap.entrySet()) {
                    if (count++ == 0) {
                        keyValues.append(" | ");
                    } else {
                        keyValues.append(", ");
                    }
                    keyValues.append(fieldEntry.getKey().toString()).append("=").
                            append(fieldEntry.getValue().toString());
                }
            }
            if (level == BLogLevel.ERROR) {
                logMessage(msg, keyValues.toString(), level, getPackagePath(),
                        (pkg, message) -> {
                            getLogger(pkg).error(message);
                        });
            } else if (level == BLogLevel.WARN) {
                logMessage(msg, keyValues.toString(), level, getPackagePath(),
                        (pkg, message) -> {
                            getLogger(pkg).warn(message);
                        });
            } else if (level == BLogLevel.INFO) {
                logMessage(msg, keyValues.toString(), level, getPackagePath(),
                        (pkg, message) -> {
                            getLogger(pkg).info(message);
                        });
            } else if (level == BLogLevel.DEBUG) {
                logMessage(msg, keyValues.toString(), level, getPackagePath(),
                        (pkg, message) -> {
                            getLogger(pkg).debug(message);
                        });
            } else {
                logMessage(msg, keyValues.toString(), level, getPackagePath(),
                        (pkg, message) -> {
                            getLogger(pkg).trace(message);
                        });
            }
        }
    }

    public static boolean isLogLevelEnabled(BString logLevel) {
        if (LOG_MANAGER.isModuleLogLevelEnabled()) {
            return LOG_MANAGER.getPackageLogLevel(getPackagePath()).value() <= BLogLevel.toBLogLevel(logLevel.getValue()).value();
        } else {
            return LOG_MANAGER.getPackageLogLevel(".").value() <= BLogLevel.toBLogLevel(logLevel.getValue()).value();
        }
    }

    public static void setModuleLogLevel(BString logLevel, Object moduleName) {
        String module;
        if (moduleName == null) {
            String className = Thread.currentThread().getStackTrace()[3].getClassName();
            String[] pkgData = className.split("\\.");
            if (pkgData.length > 1) {
                module = pkgData[0] + "/" + pkgData[1];
            } else {
                module =".";
            }
        } else {
            module = moduleName.toString();
        }
        String level = logLevel.getValue();
        LOG_MANAGER.setModuleLogLevel(BLogLevel.toBLogLevel(level), module);
    }
}
