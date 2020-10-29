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

# Represents a logger instance.
public class Logger {

    (map<anydata> & readonly)? logContext = {};

    isolated function init((map<anydata> & readonly)? logContext = ()) {
        self.logContext = logContext;
    }

    # Print the log message.
    # ```ballerina
    # log:Logger logger = log:getLogger("auditLogger");
    # logger.print(log:DEBUG, "DEBUG level log");
    # ```
    #
    # + level - Log level
    # + message - message
    public isolated function print(LogLevel level, anydata|(function () returns (anydata)) message) {
        printExtern(level, message, self.logContext);
    }
}

# Return a logger instance.
# ```ballerina
# log:Logger logger = log:getLogger("auditLogger");
# ```
#
# + context - Log context
public isolated function getLogger((map<anydata> & readonly)? context = ()) returns Logger {
    return new Logger(context);
}

isolated function printExtern(LogLevel level, anydata|(function () returns (anydata)) message,
 (map<anydata> & readonly)? logContext) = @java:Method {
    'class: "org.ballerinalang.stdlib.log.Utils"
} external;
