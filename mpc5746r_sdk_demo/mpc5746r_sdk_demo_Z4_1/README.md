# Application description

This example project is used for mpc5746r 252pin modules test based on S32 Design Studio IDE with SDK.  
  
## Development Environment & Tools

- S32 Design Studio for Power Architecture Version 2.1.
- S32_SDK_S32PA_RTM_3.0.2
- GCC E200 VLE GNU.
- MPC5746R Evaluation System: MPC5746R-252DS + MPC57XXXMB.

## How to run

### 1. Importing the project into the workspace

After opening S32 Design Studio, go to File -> New S32DS Project From... and select mpc5746r_sdk_demo_Z4_1. Then click on Finish. The project should now be copied into you current workspace.

### 2. Generating the Processor Expert configuration

First go to Project Explorer View in S32 DS and select the current project(mpc5746r_sdk_demo_Z4_1). Then go to Project and click on Generate Processor  Expert Code. Wait for the code generation to be completed before continuing to the next step.

### 3. Building the project

Select the configuration to be built FLASH (Debug_FLASH) or RAM (Debug_RAM) by left clicking on the downward arrow corresponding to the build button. Wait for the build action to be completed before continuing to the next step.

### 4. Running the project

Go to Run and select Debug Configurations. There will be two debug configurations for this project:

| Configuration Name | Description |
| ------------------ | ------------|
| mpc5746r_sdk_demo_Z4_1_Debug_RAM | Debug the RAM configuration using PEMicro debuggers |
| mpc5746r_sdk_demo_Z4_1_Debug     | Debug the FLASH configuration using PEMicro debuggers |

Select the desired debug configuration and click on Launch. Now the perspective will change to the Debug Perspective. Use the controls to control the program flow.
