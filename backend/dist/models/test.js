export var TestStatus;
(function (TestStatus) {
    TestStatus["passed"] = "passed";
    TestStatus["failed"] = "failed";
    TestStatus["skipped"] = "skipped";
    TestStatus["running"] = "running";
    TestStatus["queued"] = "queued";
})(TestStatus || (TestStatus = {}));
export var TestCategory;
(function (TestCategory) {
    TestCategory["unit"] = "unit";
    TestCategory["widget"] = "widget";
    TestCategory["integration"] = "integration";
})(TestCategory || (TestCategory = {}));
