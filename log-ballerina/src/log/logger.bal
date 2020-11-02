// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/java;

type contextMap map<anydata>;

# Represents a logger instance.
public class Logger {

    (map<anydata> & readonly)? logContext = {};
    LogLevel? logLevel = ();

    isolated function init(LogLevel? logLevel = (), (map<anydata> & readonly)? logContext = ()) {
        self.logLevel = logLevel;
        self.logContext = logContext;
    }

    # Print the log message.
    # ```ballerina
    # log:Logger logger = log:logger();
    # logger.log(log:DEBUG, "DEBUG level log");
    # ```
    #
    # + level - Log level
    # + message - message
    public isolated function log(LogLevel level, anydata|(function () returns (anydata)) message) {
        logExtern(level, message, self.logContext, self.logLevel);
    }
}

# Return a logger instance.
# ```ballerina
# log:Logger logger = log:logger();
# log:Logger logger = log:logger(log:WARN);
# ```
#
# + logLevel - Log level
# + return - A Logger
public isolated function logger(LogLevel? logLevel = ()) returns Logger {
    return new Logger(logLevel);
}

# Return a copy of a logger instance with context.
# ```ballerina
# log:Logger logger = log:logger();
# log:Logger loggerWithContext = log:loggerWithContext(logger, {id: 1234, username : "madhuka92", country: "SL"});
# ```
#
# + logger - logger
# + context - Log context
# + return - A Logger with context
public isolated function loggerWithContext(Logger logger, (map<anydata> & readonly)? context = ()) returns Logger {
    (map<anydata> & readonly) logContext = { };

    map<anydata>|error temp1;
    if (logger.logContext != ()) {
        temp1 = logger.logContext.cloneWithType(contextMap);
    } else {
        temp1 = {};
    }
    if (temp1 is error) {
    // handle the error
    } else {
        map<anydata>|error temp2 = context.cloneWithType(contextMap);
        if (temp2 is error) {
        // handle the error
        } else {
            foreach var [key, value] in temp2.entries() {
                temp1[key] = value;
            }
        }
        logContext = <map<anydata> & readonly>temp1.cloneReadOnly();
    }
    return new Logger(logLevel = (), logContext = logContext);
}

isolated function logExtern(LogLevel level, anydata|(function () returns (anydata)) message,
(map<anydata> & readonly)? logContext, LogLevel? loggerLevel) = @java:Method {
    'class: "org.ballerinalang.stdlib.log.Utils"
} external;
