# Project 6 - String Primitives and Macros

### Author: Jonathan Saks
### Last Modified: 8/12/22
### Course: CS271 Section 7
### Due Date: 8/12/22

## Description
This program takes in 10 signed integers from the user and displays each inputted number, the sum, and the average of those numbers.

## Features
- Prompts the user to input 10 signed integers.
- Displays each inputted number.
- Computes and displays the sum of the inputted numbers.
- Computes and displays the average of the inputted numbers.

## Usage
1. **Assemble and Link the Program:**
   - Ensure you have the Irvine32 library included and correctly set up in your development environment.
   - Assemble the program using an assembler like MASM.
   - Link the resulting object file to produce an executable.
   
2. **Run the Executable:**
   - Run the program.
   - The program will display instructions and prompts for input.

3. **Input:**
   - Enter 10 signed integers when prompted, one by one.
   - Make sure the integers fit inside a 32-bit register.

4. **Output:**
   - The program will display the list of entered integers.
   - The program will display the sum of these integers.
   - The program will display the truncated average value of these integers.

## Macros and Procedures

### Macros
- **mPrintCurrTotal:**
  - Displays the current total of the inputted numbers.

- **mGetString:**
  - Prompts and receives input from the user.

- **mDisplayString:**
  - Displays a string to the console.

### Procedures
- **ReadVal:**
  - Prompts the user for signed integers, validates inputs, and converts them from strings to SDWORD.

- **stringValid:**
  - Validates each character of the input string, setting the error flag accordingly.

- **validFirstChar:**
  - Validates the first character of the string, allowing for `+` or `-` signs and numbers.

- **validChar:**
  - Validates the characters of the user input to ensure they are numeric.

- **convertString:**
  - Converts the string input to SDWORD. Handles errors if the number is too big.

- **WriteVal:**
  - Converts SDWORD to a string and displays it.

- **printOut:**
  - Displays all numbers in the array, the sum, and the average.

## Dependencies
- **Irvine32 Library**
  - This program uses the Irvine32 library, which provides various I/O and string manipulation functions for MASM programs.

## Notes
- Ensure the Irvine32 library is correctly set up in your development environment before running the program.
- This program is designed to run in a Windows environment with x86 architecture.

## License
This project is licensed under the MIT License. You are free to use, modify, and distribute this software as required.
