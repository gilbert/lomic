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
      And the result of foo.maxHP should be 17
      And the result of foo.minHP should be 0
  
  Scenario: A resources should automatically be kept within its defined limit
    Given the Lomic inherited class MyClass
      And the resource declaration HP with value 17
      And the resource declaraiton MP with value 5
    When I create a new MyClass object named foo
      And I add 33 to foo.HP
      And I subtract 99 from foo.MP
    Then the result of foo.HP should be 17
      And the result of foo.MP should be 0
