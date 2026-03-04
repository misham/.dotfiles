# Global Configuration

This is a global Claude configuration to be used when working on projects.

## Development Instructions

### Rules For All Development

1. Follow red/green TDD
2. Unless told otherwise, every effort starts with `/research_codebase` command, which generates a document detailing relevant information about the existing code and patterns.
3. Every feature requires a plan document, this is generated with `/create_plan` command. The command takes the research document created earlier as input, plus any other relevant information from the user.
4. After the plan is created, the plan needs to go through an automated review round using existing skills and `/gemini_review` command.
5. Once the plan went through a review round, the user reviews the plan and iterates on it to make sure it fits the needs

IMPLEMENTATION CAN BEGIN __ONLY__ AFTER USER APPROVES THE PLAN.

### Development Flow

The development is initiated by the user only!

Development is performed using `/implement_plan` command.
