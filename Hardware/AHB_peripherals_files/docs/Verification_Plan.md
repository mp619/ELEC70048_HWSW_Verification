# Verification Plan

## Table
|     AHB_Peripheral    |     Test Number    |     Name                       |     Description                                                               |     Verification Type    |
|-----------------------|--------------------|--------------------------------|-------------------------------------------------------------------------------|--------------------------|
|     GPIO              |     1              |     Reset                      |     Ensure all GPIO outputs are held at 0 on the   negative edge of reset     |     Unit-Level           |
|                       |     2              |     Direction                  |                                                                               |     Unit-Level/Formal    |
|                       |     3              |     GPIOOUT Write              |                                                                               |     Unit-Level/Formal    |
|                       |     4              |     GPIOOUT Read               |                                                                               |     Unit-Level/Formal    |
|                       |     5              |     GPIOIN Read                |                                                                               |     Unit-Level/Formal    |
|                       |     6              |     PARITYERR GPIOIN           |                                                                               |     Unit-Level/Formal    |
|                       |     7              |     PARITYERR GPIOOUT          |                                                                               |     Unit-Level/Formal    |
|                       |     8              |     PARITY BIT GPIOOUT         |                                                                               |     Unit-Level/Formal    |
|     VGA               |     9              |     Character Print            |                                                                               |     Unit-Level           |
|                       |     10             |     Front Porch/ Back Porch    |                                                                               |     Unit-Level           |
|                       |     11             |     DLS Error                  |                                                                               |     Unit-Level/Formal    |
|                       |     12             |     Frame Width                |                                                                               |     Formal               |
|                       |     13             |     HSYNC pulse width          |                                                                               |     Formal               |
|     AHBLITE_SYS       |     14             |     GPIO Test                  |                                                                               |     Top-Level            |
|                       |     15             |     VGA Test                   |                                                                               |     Top-Level            |