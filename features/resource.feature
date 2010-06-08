Feature: resources in class declarations
  In order to remove boiler plate code
  Resources auto generate convenience methods
  Geared towards game resources
  Such as hit points and energy
  
  Scenario: Declaring a resource should generate additional variables
    Given the Lomic inherited class MyClass
      And the resource declaration HP with value 17
    When I create a new MyClass object named foo
    Then the result of foo.HP should be 17
      And the result of foo.HPmax should be 17
      And the result of foo.HPmin should be 0
  
  Scenario: A resources should automatically be kept within its defined limits
    Given the Lomic inherited class MyClass
      And the resource declaration HP with value 17
      And the resource declaration MP with value 5
    When I create a new MyClass object named foo
      And I add 33 to foo.HP
      And I subtract 99 from foo.MP
    Then the result of foo.HP should be 17
      And the result of foo.MP should be 0
  
  Scenario: Resource limits can be explicitly defined
    Given the Lomic inherited class MyClass
      And the resource declaration EXP with value [0,15,0]
      And the resource declaration STR with value [1,5]
      And the resource declaration HP with value [17]
    When I create a new MyClass object named foo
    Then the results of each <var> should be <val>:
      | var        | val |
      | foo.EXP    | 0   |
      | foo.EXPmin | 0   |
      | foo.EXPmax | 15  |
      | foo.STR    | 5   |
      | foo.STRmin | 1   |
      | foo.STRmax | 5   |
      | foo.HP     | 17  |
      | foo.HPmin  | 0   |
      | foo.HPmax  | 17  |
