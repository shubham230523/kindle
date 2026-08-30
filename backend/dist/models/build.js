export var BuildStatus;
(function (BuildStatus) {
    BuildStatus["queued"] = "queued";
    BuildStatus["running"] = "running";
    BuildStatus["successful"] = "successful";
    BuildStatus["failed"] = "failed";
})(BuildStatus || (BuildStatus = {}));
