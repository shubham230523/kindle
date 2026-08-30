export var ExecutionStatus;
(function (ExecutionStatus) {
    ExecutionStatus["idle"] = "idle";
    ExecutionStatus["waiting"] = "waiting";
    ExecutionStatus["planning"] = "planning";
    ExecutionStatus["running"] = "running";
    ExecutionStatus["completed"] = "completed";
    ExecutionStatus["failed"] = "failed";
})(ExecutionStatus || (ExecutionStatus = {}));
