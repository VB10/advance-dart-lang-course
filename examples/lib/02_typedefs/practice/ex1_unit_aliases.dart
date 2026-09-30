typedef Celsius = double;
typedef Fahrenheit = double;

Fahrenheit toFahrenheit(Celsius celsius) => celsius * 9 / 5 + 32;

Fahrenheit convertTwice(Fahrenheit fahrenheit) => toFahrenheit(fahrenheit); // Compiles.
