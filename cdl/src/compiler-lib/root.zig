//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const lexer = @import("lexer.zig");
pub const compiler = @import("compiler.zig");

test "lex cdl_test" {
    var c = compiler.Compiler.init(std.testing.allocator);
    defer c.deinit();

    const toks = try c.tokenize(cdl_test);
    try std.testing.expect(toks.len > 0);
    try std.testing.expect(toks[toks.len - 1].kind == .eof);
}

test "lex multiline string" {
    var c = compiler.Compiler.init(std.testing.allocator);
    defer c.deinit();

    const toks = try c.tokenize(cdl_multiline_string_test);
    var saw_multiline_string = false;
    for (toks) |t| {
        if (t.kind == .string and std.mem.indexOfScalar(u8, t.lexeme, '\n') != null) {
            saw_multiline_string = true;
        }
    }
    try std.testing.expect(saw_multiline_string);
}

test "dump tokens" {
    var c = compiler.Compiler.init(std.testing.allocator);
    defer c.deinit();

    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(std.testing.allocator);

    try c.dumpTokens(out.writer(std.testing.allocator), "config x { a: 1 }");
    std.debug.print("{s}", .{out.items});

    // var buf: [4096]u8 = undefined;
    // var fbs = std.io.fixedBufferStream(&buf);
    // try c.dumpTokens(fbs.writer(), "config x { a: 1 }");
    // std.debug.print("{s}", .{fbs.getWritten()});
    try std.testing.expect(out.items.len > 0);
}

const cdl_test =
\\ config access {
\\   portalid: 2995
\\   hierarchyVariable: "c320471974188.response:PH10039"
\\   //ssoConfig: @externalConfig.ssoProvider
\\   // test
\\ }\\

\\ custom properties #pptExport {
\\   templateVersion: 2
\\   reportTypeCode: "pitPhysician"
\\   hideExportsButton: @rolePermissions.m.data.hideExportsButton.doesNotHavePermission
\\   hideExecutiveOverview: @rolePermissions.m.data.executiveoverview.doesNotHavePermission
\\   primaryDimensionId: "engagement"
\\   hideResponseRate: @rolePermissions.m.data.summaryMTVResponseRate.doesNotHavePermission
\\   hidePrimaryDimFav: @rolePermissions.m.data.summaryMTVPrimaryDimFav.doesNotHavePermission
\\   hidePrimaryDimDonut: @rolePermissions.m.data.summaryMTVPrimaryDimDonut.doesNotHavePermission
\\   hideLeaderIndex: @rolePermissions.m.data.summaryMTVLeaderIndex.doesNotHavePermission
\\   hideKeyDrivers: @rolePermissions.m.data.summaryMTVKeyDrivers.doesNotHavePermission
\\   hideTopPerformingItems: @rolePermissions.m.data.summaryMTVTopPerform.doesNotHavePermission
\\   hideDimensions: @rolePermissions.m.data.summaryMTVAddDimensions.doesNotHavePermission
\\   hideDimensionsDetails: @rolePermissions.m.data.itemDetails.doesNotHavePermission
\\   hideResponseRatePh: @rolePermissions.m.data.phSummaryMTVResponseRate.doesNotHavePermission
\\   hidePrimaryDimDonutPh: @rolePermissions.m.data.phSummaryMTVPrimaryDimDonut.doesNotHavePermission
\\   hideAlignmentPh: @rolePermissions.m.data.phSummaryMTVAlignment.doesNotHavePermission
\\   hideKeyDriversPh: @rolePermissions.m.data.phSummaryMTVKeyDrivers.doesNotHavePermission
\\   hideTopPerformingItemsPh: @rolePermissions.m.data.phSummaryMTVTopPerform.doesNotHavePermission
\\   hideDimensionsPh: @rolePermissions.m.data.phSummaryMTVAddDimensions.doesNotHavePermission
\\   reportingModeValue: @rollupMode.selected.mode
\\   reportingModeLabel: @rollupMode.selectedLabel
\\ }
\\ custom properties #cp {
\\   WFRespondents: count(.respondent:, .respondent:historyTrendOrder = 1 AND .respondent:respondent = 'Yes' AND _isNotNull(surveyDataset.respondent:PH10039))
\\   WFComplete: count(:, :status = "complete" AND .response:respondent = 'Yes' AND _isNotNull(surveyDataset.response:PH10039))
\\   WFResponseRate: @cp.WFComplete / @cp.WFRespondents * 100
\\ }\\

\\ custom properties #demoPermissions {
\\   hasSensitive: @rolePermissions.m.data.demoSensitive.doesNotHavePermission = false //Should be changed later
\\   hasLimited: @rolePermissions.m.data.demoLimited.doesNotHavePermission = false //Should be changed later
\\   hasStandard: @rolePermissions.m.data.demoStandard.doesNotHavePermission = false //Should be changed later
\\ }\\

\\ reportBase {
\\   rule nodesHM #userNodeAssignment {
\\     reportingHierarchy: unitHierarchy
\\     mode: permission
\\   }
\\ }\\

\\ config programNavigation {
\\   enabled: true
\\   knowledgeBaseUrl: "https://pgemployeeexperience.zendesk.com/hc/en-us"
\\ }\\

\\ config hub {
\\   hub: 6973
\\   viaStrategy: shortest\\

\\   referenceData custom #benchmarks {
\\     table: program_config.benchmark_values:
\\     selectors: bmValueCode, TrendYear, benchmarkDefinitionID, hasPercentile
\\     array #Per {
\\       size: 99
\\     }
\\   }\\

\\   referenceData custom #benchmarksById {
\\     table: program_config.benchmark_values:
\\     selectors: bmValueCode, BenchmarkId//, Type
\\     array #Per {
\\       size: 99
\\     }
\\   }
\\   referenceData custom #sigTestThresholds {
\\     table: program_config.sigtest_thresholds:
\\     selectors: n1, n2, threshold//, Type
\\     array #Per {
\\       size: 99
\\     }
\\   }
\\   referenceData custom #benchmarkSubgroupings {
\\     table: program_config.benchmark_subgroupings:
\\     selectors: bmValueCode, demographicItemID, primaryBenchmarkID, reportType, trendYear, demographicItemAnswerCode
\\     array #Per {
\\       size: 99
\\     }
\\   }\\

\\   //dimensionScoreOverall
\\   referenceData custom #dimensionScoreLookup {
\\     table: dimensionScore.dimensionScoreOverall:
\\     selectors: idText, historyTrendOrder
\\   }
\\   //itemScoreOverall
\\   referenceData custom #itemScoreLookup {
\\     table: itemScore.itemScoreOverall:
\\     selectors: idText, historyTrendOrder
\\   }\\
\\

\\   reportingHierarchy selfRefLookup #unitHierarchy {
\\     label: "WF to HX - Employee Engagement"
\\     //source: studio.expressionFromCdl("surveyDataset.response" + @externalConfig.hierarchyItemID), studio.expressionFromCdl("surveyDataset.respondent" + @externalConfig.hierarchyItemID)
\\     source: studio.expressionFromCdl("surveyDataset.response:PH10039"), studio.expressionFromCdl("surveyDataset.respondent:PH10039")
\\     nodeSorting: natural
\\     showBreadcrumb: true
\\   }\\

\\   dataset custom #project_config {
\\     publicName: "project_config_c320471974188"
\\     defaultTable: report_history //need one to be default
\\   }\\

\\   dataset custom #dimensionScore {
\\     publicName: "c320471974188"
\\     defaultTable: dg1_dimensionScore
\\     table dimension_score = .dg1_dimensionScore:
\\     table metadata = .dg1_dimensions:
\\     measure custom #score {
\\       value: avg(:dimensionScoreValue)
\\     }
\\     variable auto #id {
\\       table: :
\\       value: :dg1_dimensionScore
\\     }
\\     variable text #idText {
\\       table: :
\\       value: toText(:dg1_dimensionScore)
\\     }\\

\\     variable auto #scoreValue {
\\       table: :
\\       value: :dimensionScoreValue
\\     }\\

\\     vtable custom #dimensionScoreOverall {
\\       variable auto #score {
\\         value: avg(:dimensionScoreValue)
\\       }
\\       variable auto #count {
\\         value: count(:dimensionScoreValue)
\\       }
\\       variable text #idText {
\\         value: toText(:dg1_dimensionScore)
\\         isKey: true
\\         groupBy: values
\\       }
\\       variable auto #historyTrendOrder {
\\         value: :historyTrendOrder
\\         groupBy: values
\\         isKey: true
\\       }
\\       filter expression {
\\         value: .response:respondent = 'Yes' AND .response:status = "complete"
\\       }
\\     }
\\   }
\\   dataset custom #itemScore {
\\     publicName: "c320471974188"
\\     defaultTable: dg1_questionScore
\\     table dimension_score = .dg1_dimensionScore:
\\     table metadata = .dg1_questions:
\\     measure custom #score {
\\       value: avg(:questionScoreValueNumeric)
\\     }
\\     variable auto #id {
\\       table: :
\\       value: :dg1_questionScore
\\     }
\\     variable auto #scoreValue {
\\       table: :
\\       value: :questionScoreValueNumeric
\\     }
\\     variable auto #engagementFourPoint {
\\       table: :
\\       value: :threePoint
\\     }\\

\\     vtable custom #itemScoreOverall {
\\       variable auto #score {
\\         value: avg(:questionScoreValueNumeric)
\\       }
\\       variable auto #count {
\\         value: count(:questionScoreValueNumeric)
\\       }
\\       variable text #idText {
\\         value: toText(:dg1_questionScore)
\\         isKey: true
\\         groupBy: values
\\       }
\\       variable auto #historyTrendOrder {
\\         value: :historyTrendOrder
\\         groupBy: values
\\         isKey: true
\\       }
\\       filter expression {
\\         value: .response:respondent = 'Yes' AND .response:status = "complete"
\\       }
\\     }
\\   }
\\   dataset custom #reports {
\\     publicName: program_config
\\     defaultTable: project_reports
\\   }\\
\\

\\   dataset survey #surveyDataset {
\\     publicName: "c320471974188"\\

\\     table dimensions = .dg1_dimensions:
\\     table items = .dg1_questions:
\\     table benchmarks = project_config.benchmark_list:
\\     table scaled_items = project_config.scaled_items:
\\     table dimensionItems = .dg1_dimension_question:
\\     table rolePermissions = program_config.role_permissions:
\\     table allPermissions = program_config.allPermissions:
\\     table widgetConfig = program_config.report_Widgets:
\\     table reportHistory = project_config.report_history:
\\     table demo_items = program_config.demo_items:
\\     table open_items = program_config.open_items:
\\     table dimension_score = .dg1_dimensionScore:
\\     table item_score = .dg1_questionScore:
\\     table dimensionItems = .dg1_dimension_question:
\\     table projectPeriods = project_config.project_periods:\\

\\     vtable custom #dimensionLeaderIndexOverall {
\\       variable auto #score {
\\         value: avg(.dimension_score:dimensionScoreValue)
\\       }
\\       variable auto #id {
\\         value: .dimension_score:dg1_dimensionScore
\\         isKey: true
\\         groupBy: values
\\       }
\\       filter expression {
\\         value: .dimension_score:historyTrendOrder = 1
\\       }\\

\\       filter expression {
\\         value: .response:respondent = 'Yes' AND .response:status = "complete"
\\       }
\\       filter expression {
\\         value: .dimension_score:dg1_dimensionScore = "leaderindex"
\\       }\\

\\     }\\
\\
\\

\\     propagateFilter {
\\       from: .dimensions:
\\       to: .dimensionItems:
\\     }
\\     propagateFilter {
\\       from: .dimensionItems:
\\       to: .items:
\\     }\\

\\     relation oneToMany {
\\       primaryKey: .scaled_items:itemid
\\       foreignKey: .items:id
\\     }\\

\\     relation oneToMany {
\\       primaryKey: .allPermissions:permissionsCode
\\       foreignKey: .rolePermissions:permissionsCode
\\     }
\\     relation oneToMany {
\\       primaryKey: .reportHistory:historyTrendOrder
\\       foreignKey: :historyTrendOrder
\\     }
\\     relation oneToMany {
\\       primaryKey: .periods:survey
\\       foreignKey: :combined_sourceid
\\     }
\\     relation oneToMany {
\\       primaryKey: .surveys:code
\\       foreignKey: :combined_sourceid
\\     }
\\     relation oneToMany {
\\       primaryKey: .projectPeriods:periodID
\\       foreignKey: .benchmarks:periodID
\\     }
\\     relation oneToMany {
\\       primaryKey: .projectPeriods:periodID
\\       foreignKey: .reportHistory:periodID
\\     }\\

\\     measure custom #leaderIndexMeasure {
\\       value: IIF(round(avg(.dimension_score:dimensionScoreValue, true, unitHierarchy:), 2) <= 2.5, "Low", IIF(round(avg(.dimension_score:dimensionScoreValue, true, unitHierarchy:), 2) >= 4, "High", "Moderate"))
\\       option {
\\         code: "Low"
\\         label: "Low"
\\       }
\\       option {
\\         code: "Moderate"
\\         label: "Moderate"
\\       }
\\       option {
\\         code: "High"
\\         label: "High"
\\       }
\\     }\\

\\     measure custom #dimensionScore {
\\       value: avg(.dimension_score:dimensionScoreValue)
\\     }
\\     measure custom #itemScore {
\\       value: avg(.item_score:questionScoreValueNumeric)
\\     }\\

\\     variable numeric #forDimension {
\\       table: :
\\       value: avg(.dimension_score:dimensionScoreValue, .dimension_score:dg1_dimensionScore = "engagement", :)
\\     }
\\     variable numeric #forSecondaryDimension {
\\       table: :
\\       value: avg(.dimension_score:dimensionScoreValue, .dimension_score:dg1_dimensionScore = "alignment", :)
\\     }\\
\\

\\    //TODO: can we get rid of this hardcoding?
\\     recoding ranges #LeaderIndexGroup {
\\       intervals: leftopen
\\       mapping {
\\         to: "Low"
\\         from: "..2.5"
\\       }
\\       mapping {
\\         to: "Moderate"
\\         from: "2.51..3.99"
\\       }
\\       mapping {
\\         to: "High"
\\         from: "4.00.."
\\       }\\
\\

\\     }
\\     recoding ranges #EngagementGroup {
\\       intervals: leftopen
\\       mapping {
\\         to: "Low"
\\         from: "..3.75"
\\       }
\\       mapping {
\\         to: "Moderate"
\\         from: "3.75..4.99"
\\       }
\\       mapping {
\\         to: "High"
\\         from: "5.."
\\       }
\\     }
\\     recoding values #FivePointsGrouping {
\\       intervals: leftopen
\\       mapping {
\\         to: "Strongly Disagree"
\\         from: "1"
\\       }
\\       mapping {
\\         to: "Disagree"
\\         from: "2"
\\       }
\\       mapping {
\\         to: "Neutral"
\\         from: "3"
\\       }
\\       mapping {
\\         to: "Agree"
\\         from: "4"
\\       }
\\       mapping {
\\         to: "Strongly Agree"
\\         from: "5"
\\       }
\\     }
\\     measure filter #filterMeasure_foreNPS {
\\       value: IN(:EV22745, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10")
\\       label: "is answered"
\\     }
\\     variable singleChoice #EV22745__NPS {
\\       table: :
\\       value: recode(:EV22745, @_NPS)
\\       label: "On a scale from 0-10, how likely are you to recommend this organization to others as a place to work?"
\\     }
\\     variable singleChoice #EV22744__NPS {
\\       table: :
\\       value: recode(:EV22744, @_NPS)
\\       label: "On a scale from 0-10, how likely are you to recommend this organization to your family or friends as a place to receive care?"
\\     }
\\     variable singleChoice #BreakDownByValues {
\\       table: .item_score:
\\       value: IIF(IN(.item_score:questionScoreValue, "9", "10"), "3", IIF(IN(.item_score:questionScoreValue, "7", "8"), "2", "1"))\\

\\       option code {
\\         code: "3"
\\         score: 3
\\         label: "Promoters"
\\       }
\\       option code {
\\         code: "2"
\\         score: 2
\\         label: "Passives"
\\       }\\

\\       option code {
\\         code: "1"
\\         score: 1
\\         label: "Detractors"
\\       }
\\     }
\\     vtable custom #systemLevelItems {
\\       parent {
\\         table: .items:
\\         type: oneToOne
\\       }
\\       filter expression {
\\         value: .response:respondent = 'Yes' AND .response:status = "complete"
\\       }
\\       filter expression {
\\         value: .items:includeKD
\\       }
\\       filter expression {
\\         value: .respondent:historyTrendOrder = 1
\\       }
\\       filter expression {
\\         value: _isNotNull(:forDimension)
\\       }
\\       variable auto #id {
\\         value: toText(.items:id)
\\       }
\\       variable numeric #correlation {
\\         value: correlation(score(.item_score:questionScoreValue), :forDimension, true, .items:)
\\       }
\\       variable numeric #correlationSecondaryDimension {
\\         value: correlation(score(.item_score:questionScoreValue), :forSecondaryDimension, true, .items:)
\\       }
\\     }
\\   }
\\   dataset custom #textAnalyticsDataset {
\\     publicName: "TextAnalytics_c320471974188_70067"
\\     table responses = surveyDataset.response:
\\     defaultTable: overallScore\\

\\     reportingHierarchy selfRefCustom #categoryHierarchy {
\\       label: "Categories model"
\\       mode: "direct"
\\       parent: .model:parent
\\       nodeLabel: .model:label
\\     }
\\     recoding ranges #recodeSentiments {
\\       intervals: "leftopen"
\\       method: "case"
\\       mapping #mapping {
\\         from: "0.25.."
\\         to: "Positive"
\\       }
\\       mapping #mapping_2 {
\\         from: "-0.25..0.25"
\\         to: "Neutral"
\\       }
\\       mapping #mapping_3 {
\\         from: "..-0.25"
\\         to: "Negative"
\\       }
\\     }
\\     measure custom #responseCategoryGroup {
\\       value: recode(.categoryScore:score, @recodeSentiments)
\\       label: "Average Sentiment across categories Recoded"
\\     }
\\   }
\\   dataSet: surveyDataset\\

\\   dataTable #dtuserFilter {
\\     dataGrid {
\\       row #user {\\

\\       }
\\       column #filter {\\

\\         cell custom {
\\           expression #value {
\\             value: isNull(first(project_config.UserFilters:UserFilterExpression, project_config.UserFilters:UserFilterExpression, project_config.UserFilters:EmailAddress = @currentUser.emailaddress), "true")
\\           }
\\           formatString: "value is: {value}"
\\         }
\\       }
\\     }
\\   }\\

\\   dataTable #dtbenchmarkSelectorOption {
\\     dataGrid {
\\       row #user {\\

\\       }
\\       column #selection {\\

\\         cell custom {
\\           formula #id {
\\             value: IIF(false, @defaultBenchmmarkEV.selected.id, @defaultBenchmmarkPH.selected.id)
\\             formatter: bigNumberFormatter
\\           }
\\           formula #idInt {
\\             value: IIF(false, @defaultBenchmmarkEV.selected.idInt, @defaultBenchmmarkPH.selected.idInt)
\\             formatter: bigNumberFormatter
\\           }
\\           formula #idText {
\\             value: IIF(false, @defaultBenchmmarkEV.selected.idText, @defaultBenchmmarkPH.selected.idText)\\

\\           }
\\           formula #periodId {
\\             value: IIF(false, @defaultBenchmmarkEV.selected.periodId, @defaultBenchmmarkPH.selected.periodId)
\\             formatter: bigNumberFormatter
\\           }
\\           formula #definitionId {
\\             value: IIF(false, @defaultBenchmmarkEV.selected.definitionId, @defaultBenchmmarkPH.selected.definitionId)
\\             formatter: bigNumberFormatter
\\           }
\\           formula #definitionName {
\\             value: IIF(false, @defaultBenchmmarkEV.selected.definitionName, @defaultBenchmmarkPH.selected.definitionName)
\\             formatter: bigNumberFormatter
\\           }
\\           formatString: "ID is: {id} | idText is: {idText} | definitionName is: {definitionName}  "
\\         }
\\       }
\\     }
\\   }
\\   dataTable #dtUserRolePermissions {
\\     dataGrid #dgUserRolePermissions {\\

\\       filter expression {
\\         value: hierarchy18039.NodeAssignments:UserName = @currentUser.emailaddress
\\       }\\

\\       row list #demos {
\\         total: none
\\         take: 1
\\         table: studio.expressionFromCdl("hierarchy18039.NodeAssignments:")
\\         value: studio.expressionFromCdl("hierarchy18039.NodeAssignments:UserName")\\

\\       }
\\       column #main {
\\         cell custom {
\\           expression #role {
\\             value: IsNull(studio.expressionFromCdl("hierarchy18039.NodeAssignments:Role"), "NoRole")
\\           }
\\           expression #label {
\\             value: IsNull(studio.expressionFromCdl("hierarchy18039.NodeAssignments:UserName"), "NoRole")
\\           }
\\           formatString: "{role} {label}"
\\         }
\\       }
\\     }
\\     map #forSelect {
\\       from: "demos"
\\       to: item {
\\         label: this.main.label
\\         value: this.main.role
\\       }
\\       ifEmpty: item {
\\         label: "NoRole"
\\         value: "NoRole"
\\       }
\\     }
\\   }
\\   dataTable #dtRolePermissionsException {
\\     dataGrid #dgRolePermissionsException {
\\       row #user {\\

\\       }
\\       column #roleCheck {
\\         cell custom {
\\           expression #roleSelection {
\\             value: IIF(@dtUserRolePermissions.forSelect.data.value = "NoRole", IIF(Contains(@currentUser.emailaddress, "@pressganey.com") OR Contains(@currentUser.emailaddress, "@forsta.com"), "pgfAdmin", "NoRole"), @dtUserRolePermissions.forSelect.data.value)\\

\\           }
\\           formatString: "{roleSelection}"\\

\\         }
\\       }
\\     }
\\   }\\

\\   //Selector content for response rate page
\\   dataTable #dtResponseRateItems {
\\     dataGrid #dgresponseRateItems {
\\       size: large
\\       row #rritems {
\\         row #orgunithier {
\\           cell custom {
\\             expression #id {
\\               value: ":PH10039"
\\             }
\\             expression #label {
\\               value: "Organization hierarchy - Hierarchy"
\\             }
\\             expression #demoDisplayType {
\\               value: "background"
\\             }
\\             expression #rows {
\\               value: "hier"
\\             }
\\             expression #cols {
\\               value: "invited, responded, rate"
\\             }
\\             formatString: "{id} {label}"
\\           }
\\         }
\\         row #orgunit {
\\           cell custom {
\\             expression #id {
\\               value: ":PH10039"
\\             }
\\             expression #label {
\\               value: "Organization hierarchy - Flat"
\\             }
\\             expression #demoDisplayType {
\\               value: "background"
\\             }
\\             expression #rows {
\\               value: "units"
\\             }
\\             expression #cols {
\\               value: "invited, responded, rate, rollup" //"rollup"
\\             }
\\             formatString: "{id} {label}"
\\           }
\\         }
\\         //TODO: Only list demographics user have access to!
\\         row list #demos {
\\           total: none
\\           table: .demo_items:
\\           value: ""
\\           filter expression {
\\             value: .demo_items:cmbdSurveyPID = "c320471974188"
\\           }
\\           filter expression {
\\             //here should be filter end user specific
\\             value: IIF(@rolePermissions.m.data.demoSensitive.doesNotHavePermission = false, .demo_items:demoPermissionTypeCode = "sensitive", .demo_items:demoPermissionTypeCode = "") OR IIF(@rolePermissions.m.data.demoLimited.doesNotHavePermission = false, .demo_items:demoPermissionTypeCode = "limited", .demo_items:demoPermissionTypeCode = "None") OR IIF(@rolePermissions.m.data.demoStandard.doesNotHavePermission = false, .demo_items:demoPermissionTypeCode = "standard", .demo_items:demoPermissionTypeCode = "")
\\           }
\\           cell custom {
\\             expression #id {
\\               value: IIF(.demo_items:demoDisplayType = "selfselect", studio.expressionFromCdl("surveyDataset:" + .demo_items:itemID), studio.expressionFromCdl(".respondent:" + .demo_items:itemID))
\\             }
\\             expression #label {
\\               value: .demo_items:itemLabel
\\             }
\\             expression #demoDisplayType {
\\               value: isNull(.demo_items:demoDisplayType, '')
\\             }
\\             expression #rows {
\\               value: "cut"
\\             }\\

\\             expression #cols {
\\               value: "invited, responded, rate"
\\             }
\\             formatString: "{id} {label}"
\\           }
\\         }
\\       }
\\       row list #hackBecauseOfBug {
\\         total: first
\\         table: .demo_items:
\\         value: ""
\\         filter expression {
\\           value: .demo_items:itemID = 'NonExisting'
\\         }
\\         cell {
\\           value: ''
\\         }
\\       }
\\       column #main {\\

\\       }
\\     }
\\     map #forSelect2 {
\\       from: "rritems"
\\       to: item {
\\         label: this.main.label
\\         value: {
\\           id: this.main.id
\\           col: studio.expressionFromCdl(this.main.cols)
\\           row: this.main.rows
\\           demoDisplayType: this.main.demoDisplayType
\\         }
\\       }
\\     }
\\   }\\

\\   //Calculating available rollup modes depending on where in the hierarchy user is
\\   dataTable #dtModes {
\\     dataGrid #dgModes {
\\       removeEmptyRows: true
\\       row #nodes {
\\         //hide: true
\\         cell {
\\           value: IIF(count(unitHierarchy:) != countIf(IsLeaf(unitHierarchy:^hierarchy)), "PARENT", "LEAF")
\\         }
\\       }\\

\\       row #variants {
\\         row #v1 {
\\           cell custom {
\\             formula #label {
\\               value: IIF([row = /nodes] = "PARENT", "My Team View")
\\             }
\\             formula #mode {
\\               value: IIF([row = /nodes] = "PARENT", "rollup")
\\             }
\\             formula #gridMode {
\\               value: IIF([row = /nodes] = "PARENT", "rollup")
\\             }
\\             formatString: "{label} {mode} {gridMode}"
\\           }
\\         }
\\         row #v2 {
\\           hide: @dtLeafNotLeaf.m.data.status.hideForLeafs
\\           cell custom {
\\             formula #label {
\\               value: IIF([row = /nodes] = "PARENT", "Direct Reports")
\\             }
\\             formula #mode {
\\               value: IIF([row = /nodes] = "PARENT", "direct")
\\             }
\\             formula #gridMode {
\\               value: IIF([row = /nodes] = "PARENT", "mixed")
\\             }
\\             formatString: "{label} {mode} {gridMode}"
\\           }
\\         }
\\         row #v3 {
\\           cell custom {
\\             formula #label {
\\               value: IIF([row = /nodes] = "LEAF", "My Team (as Direct)")
\\             }
\\             formula #mode {
\\               value: IIF([row = /nodes] = "LEAF", "direct")
\\             }
\\             formula #gridMode {
\\               value: IIF([row = /nodes] = "LEAF", "mixed")
\\             }
\\             formatString: "{label} {mode} {gridMode}"
\\           }
\\         }
\\       }
\\       column #status {
\\       }
\\     }
\\     map #forSelect {
\\       from: "variants"
\\       to: item {
\\         label: this.status.label
\\         value: {
\\           mode: this.status.mode
\\           gridMode: this.status.gridMode
\\         }
\\       }
\\     }
\\   }\\

\\   dataTable #rolePermissions {
\\     dataGrid {
\\       filter expression {
\\         value: .rolePermissions:cmbdSurveyPID = "c320471974188" AND .rolePermissions:roleCode = @userRole.selected
\\       }\\

\\       column #permission {
\\         cell {
\\           value: .allPermissions:permissionsCode
\\         }
\\       }
\\       column #permissionCount {
\\         cell {
\\           value: count(.rolePermissions:permissionsCode)
\\         }
\\       }
\\       column #isHidden {
\\         cell {
\\           value: count(.rolePermissions:permissionsCode) = 0
\\         }
\\       }
\\       row list #permissions {
\\         total: none
\\         table: .allPermissions:
\\         value: .allPermissions:permissionsCode
\\       }
\\       column #c {
\\         cell custom {
\\           expression #permission {
\\             value: not(some(.rolePermissions:, true, .allPermissions:))
\\           }
\\           expression #key {
\\             value: .allPermissions:permissionsCode
\\           }
\\           formatString: ""
\\         }
\\       }
\\     }
\\     map #m {
\\       toRecord byKey {
\\         key: this.c.key
\\       }
\\       from: "permissions"
\\       to: {
\\         doesNotHavePermission: this.c.permission //Change this For Role Permissions
\\       }
\\     }
\\     map #permissionLookup {
\\       from: "permissions"
\\       to: {
\\         permission: this.permissionCount.value
\\         isHidden: this.isHidden.value
\\       }
\\       toRecord byKey {
\\         key: this.permission.value
\\       }
\\     }\\

\\   }\\

\\   dataTable #widgetConfig {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid {
\\       label: "Data Grid"
\\       size: "large"
\\       filter expression {
\\         value: .widgetConfig:cmbdSurveyPID = "c320471974188"
\\       }
\\       column #widgetCode {
\\         cell {
\\           value: .widgetConfig:widgetCode
\\         }
\\       }
\\       column #widgetLabel {
\\         cell {
\\           value: .widgetConfig:widgetLabel
\\         }
\\       }
\\       column #widgetDescription {
\\         cell {
\\           value: .widgetConfig:widgetDescription
\\         }
\\       }
\\       column #widgetInfoText {
\\         cell {
\\           value: .widgetConfig:widgetInfoText
\\         }
\\       }
\\       row list #widgetCodes {
\\         table: .widgetConfig:
\\         value: .widgetConfig:widgetCode
\\       }
\\     }
\\     map #lookup {
\\       from: "widgetCodes"
\\       to: {
\\         label: this.widgetLabel.value
\\         description: this.widgetDescription.value
\\         infoText: this.widgetInfoText.value
\\       }
\\       toRecord byKey {
\\         key: this.widgetCode.value
\\       }
\\     }
\\   }\\

\\   //dataTable getting list of dimensions from table .dimensions: to fill in selectors, including what is default
\\   dataTable #dtDimensions {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid #dgDimensions {
\\       row list #dimensions {
\\         total: none
\\         table: .dimensions:
\\         value: ""
\\         sortBy: "/_label"
\\         sortOrder: ascending
\\       }\\

\\       column #results {
\\         cell custom {
\\           expression #label {
\\             value: .dimensions:id //[column = /_label]
\\           }
\\           expression #type {
\\             value: "leader" //.dimensions:typeMG
\\           }
\\           expression #id {
\\             value: toText(.dimensions:id)
\\           }
\\           expression #isDefault {
\\             value: .dimensions:isPrimary
\\           }
\\           formula #points {
\\             value: IIF(type[] = "Engagement", "fourPoint", "threePoint")
\\           }
\\           formatString: "{label} | {type} | {id} | {isDefault}"
\\         }
\\       }
\\     }
\\     map #forSelect {
\\       from: "dimensions"
\\       to: item {
\\         label: this.results.id
\\         value: {
\\           id: this.results.id
\\           type: this.results.type
\\           isDefault: this.results.isDefault
\\           points: this.results.points
\\         }
\\       }
\\     }
\\     map #forSelect2 {
\\       from: "dimensions"
\\       to: item {
\\         label: this.results.label
\\         value: this.results.id
\\         isDefault: this.results.isDefault
\\       }
\\     }
\\   }
\\   dataTable #dtItems {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid #dgItems {
\\       row list #items {
\\         total: none
\\         table: .items:
\\         value: ""
\\         sortBy: "/num"
\\         sortOrder: ascending
\\       }
\\       column #num {
\\         hide: true
\\         cell {
\\           value: .items:sequenceId
\\           extraValue: toText(.items:sequenceId)
\\         }
\\       }
\\       column #results {
\\         cell custom {
\\           expression #label {
\\             value: .items:label
\\           }
\\           formula #fullLabel {
\\             value: extraValue[column = /num] + ". " + label[]
\\           }
\\           expression #id {
\\             value: toText(.items:id)
\\           }
\\           formatString: ""
\\         }
\\       }
\\     }
\\     map #forSelect {
\\       from: "items"
\\       to: item {
\\         label: this.results.fullLabel
\\         value: this.results.id\\

\\       }
\\     }
\\   }
\\   dataTable #dtSurveys {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid #dgSurveys {
\\       row list #surveys {
\\         filter expression {
\\           value: .reportHistory:historyTrendOrder != 1\\

\\         }
\\         total: none
\\         table: .reportHistory:
\\         value: ""
\\       }
\\       column #col {
\\         cell custom {
\\           expression #id {
\\             value: .reportHistory:historyTrendOrder
\\           }
\\           expression #label {
\\             value: .reportHistory:historyLabel
\\           }
\\           expression #code {
\\             value: .reportHistory:prjSurveyPID
\\           }
\\           expression #isDefault {
\\             value: .reportHistory:historyTrendOrder = 2
\\           }
\\           expression #trendOrder {
\\             value: toText(.reportHistory:historyTrendOrder)
\\           }
\\           formula #columnToDisplay {
\\             value: "surveys"
\\           }
\\           formatString: ""
\\         }
\\       }
\\     }
\\     map #forSelect {
\\       from: surveys
\\       to: item {
\\         label: this.col.label
\\         value: {
\\           id: this.col.id
\\           isDefault: this.col.isDefault
\\           trendOrder: this.col.trendOrder
\\           col: this.col.columnToDisplay
\\         }
\\       }
\\       ifEmpty: item {
\\         label: "NoHistory"
\\         value: {
\\           id: "NoHistory"
\\           isDefault: false
\\           trendOrder: 99
\\           col: "surveys"
\\         }
\\       }
\\     }\\

\\   }\\

\\   dataTable #dtDisplayHistory {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid {
\\       row #r {
\\       }
\\       column #c {
\\       }
\\       cell {
\\         value: IIF(count(.reportHistory:) > 1, "flex", "none")
\\       }
\\     }
\\     map #m {
\\       from: r
\\     }
\\   }\\

\\   dataTable #dtBenchmarks {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid {
\\       row list #benchmarks {
\\         total: none
\\         table: .benchmarks:
\\         value: ""
\\         sortBy: "/order"
\\         sortOrder: ascending
\\       }
\\       filter expression {
\\         value: .benchmarks:display = true
\\       }
\\       column #order {
\\         hide: true
\\         cell {
\\           value: .benchmarks:benchmarkOrder
\\         }
\\       }
\\       column #results {
\\         cell custom {
\\           expression #label {
\\             value: .benchmarks:benchmarkName
\\           }
\\           expression #id {
\\             value: .benchmarks:BenchmarkID
\\           }
\\           expression #idText {
\\             value: toText(.benchmarks:BenchmarkID)
\\           }\\

\\           expression #definitionId {
\\             value: .benchmarks:BenchmarkDefinitionID
\\           }
\\           expression #definitionName {
\\             value: .benchmarks:BenchmarkDefinitionName
\\           }
\\           expression #periodId {
\\             value: .benchmarks:TrendYear
\\           }
\\           expression #order {
\\             value: toText(.benchmarks:id)
\\           }
\\           expression #isDefault {
\\             value: .benchmarks:benchmarkIsPrimary\\

\\           }
\\           formula #columnToDisplay {
\\             value: "bench"
\\           }
\\           formatString: "{label} {definitionId} {isDefault}"
\\         }
\\       }
\\     }
\\     map #forSelect {
\\       from: "benchmarks"
\\       to: item {
\\         label: this.results.label
\\         value: {
\\           id: this.results.id
\\           idInt: this.results.id
\\           periodId: this.results.periodId
\\           definitionId: this.results.definitionId
\\           definitionName: this.results.label
\\           idText: this.results.idText
\\           col: this.results.columnToDisplay
\\         }
\\       }
\\     }
\\     map #forDefaultSelector {
\\       from: "benchmarks"
\\       to: item {
\\         label: this.results.label
\\         value: {
\\           id: this.results.id
\\           idInt: this.results.id
\\           periodId: this.results.periodId
\\           definitionId: this.results.definitionId
\\           definitionName: this.results.label
\\           idText: this.results.idText
\\           isDefault: this.results.isDefault\\

\\         }
\\       }
\\     }
\\   }
\\   dataTable #dtSurveyCurrent {
\\     ignoreFilters: userNodeAssignment
\\     dataGrid #dgSurveys {
\\       row list #surveys {
\\         filter expression {
\\           value: .reportHistory:historyTrendOrder = 1\\

\\         }
\\         total: none
\\         table: .reportHistory:
\\         value: ""
\\       }
\\       column #col {
\\         cell custom {
\\           expression #id {
\\             value: .reportHistory:historyTrendOrder
\\           }
\\           expression #label {
\\             value: .reportHistory:historyLabel
\\           }
\\           expression #code {
\\             value: .reportHistory:prjSurveyPID
\\           }
\\           expression #isDefault {
\\             value: .reportHistory:historyTrendOrder = 1
\\           }
\\           expression #trendOrder {
\\             value: toText(.reportHistory:historyTrendOrder)
\\           }
\\           formatString: ""
\\         }
\\       }
\\     }
\\     map #forSelect {
\\       from: surveys
\\       to: item {
\\         label: this.col.label
\\         value: this.col.id
\\         isDefault: this.col.isDefault
\\         trendOrder: this.col.trendOrder
\\       }
\\     }
\\   }\\

\\   categorySet #openItems {
\\     question: textAnalyticsDataset.overallScore:variable
\\   }
\\ }
;

const cdl_multiline_string_test =
\\ config access {
\\   hierarchyVariable: "line1
\\ line2"
\\ }
;