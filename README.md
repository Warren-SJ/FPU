# FPU
 A Floating Point Unit which has been created in SystemVerilog and Verilog. The module contains the following capabilities:

 * Addition of 2 floating point numbers.
 * Subtraction of 2 floating point numbers.
 * Multiplication of 2 floating point numbers.
 * Division of 2 floating point numbers.
   
### A bit about the IEEE 754 standard

The IEEE 754 standard is a widely used standard for floating point numbers in computers. It defines the format of floating point numbers and the operations that can be performed on them. The standard defines 3 formats for floating point numbers: single precision, double precision, and extended precision. The FPU module in this repository uses the single precision format.

The single precision format consists of 32 bits, divided into 3 parts: the sign bit, the exponent, and the mantissa. The sign bit is used to represent the sign of the number, with 0 representing a positive number and 1 representing a negative number. The exponent is used to represent the magnitude of the number, and the mantissa is used to represent the precision of the number.

Any floating point number can be represented in the following form:

$$ (-1)^s * 2^(e-127) * 1.m $$

Where s is the sign bit, e is the exponent, and m is the mantissa. Here, it can be noticed that the exponent is biased by 127. This is done to allow for both positive and negative exponents to be represented.

### Flags

The FPU module also contains flags that indicate the status of the result of the operation. The flags are as follows:

* Normal: Indicates that the result is a normal number.
* Subnormal: Indicates that the result is a subnormal number.
* Zero: Indicates that the result is zero.
* Infinity: Indicates that the result is infinity.
* Quiet NaN: Indicates that the result is a quiet NaN.
* Signaling NaN: Indicates that the result is a signaling NaN.

Normal numbers are numbers that can be represented in the IEEE 754 format. Subnormal numbers are numbers that are too small to be represented in the IEEE 754 format. This is the case when the exponent is all zeros. Zero is represented by all zeros in the exponent and mantissa. Infinity is represented by all ones in the exponent and zeros in the mantissa. Quiet NaN is represented by all ones in the exponent and a non-zero mantissa. Signaling NaN is represented by all ones in the exponent and a zero mantissa.
