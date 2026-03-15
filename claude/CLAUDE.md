# Global Configuration

This is a global Claude configuration to be used when working on projects.

## Development Instructions

### Rules For All Development

1. Follow red/green TDD
2. Unless told otherwise, every effort starts with `/development-flow:gather_requirements` command, which generates a document detailing relevant requirements for the feature.
3. Once requirements document is created, it is followed by `/development-flow:research_codebase`, which generates a document detailing relevant information about the existing code and patterns.
4. Every feature requires a plan document, this is generated with `/development-flow:create_plan` command. The command takes the requirements and research documents created earlier as input, plus any other relevant information from the user.
5. After the plan is created, the plan needs to go through an automated review round using existing skills and `/thorough-review:thorough-review` command. Any issues the user deems necessary are fixed and the plan goes through a second round of review. After the second round, the user marks which issues still need to be fixed in the plan.
6. Once the plan went through two review rounds, the feature is implemented using `/development-flow:implement_plan`, which takes the plan created in step 5 as input.
7. After the implementation and automated testing, `/development-flow:validate` command is run. It accepts the plan as input and references the research and requirements document. This includes review of the code and implementation based on requirements and validation information gathered in steps 2 and 3.
8. If validation step identifies any issues with the code or requirements completeness, those are presented to the user for review. The user identifies which issues to fix.
9. After the fixes from validation-identified issues are fixed, `/development-flow:validate` is run again. If any other issues are identified, the user is asked which ones need to be addressed.
10. This may continue for NO MORE THAN 3 rounds. If there are still issues after the third round of validation, the user needs to weigh on the implementation of the feature. Present to the user possible reasons for continuing issues in priority order with explanations and references.
11. Once the user is satisfied with the feature implementation, perform `/development-flow:thorough-review` of the code and include in that security checks as well. Present any issues to the user to address.
12. When the user is satisfied, run `/development-flow:compact_plan` for the plan created in step 4.
13. Last step is to ask the user if they want to commit the changes using `/development-flow:commit`

## Important Notes:

- IMPLEMENTATION CAN BEGIN __ONLY__ AFTER USER APPROVES THE PLAN.
- Always use parallel Task agents to maximize efficiency and minimize context usage
- Always follow red/green TDD for any code changes
- If tests do not exist for the code being added or changed, add them.

