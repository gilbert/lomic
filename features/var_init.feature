Feature: variable declaration and initialization on new objects
  Scenario: Use of var after new object initializes
    Given the Lomic inherited class MyClass
    And the following var declarations:
      | var_decl          |
      | var :example => 9 |
      | var :another => 3 |
    When I create a new MyClass object named foo
    Then the result of foo.example should be 9
    And  the result of foo.another should be 3
