Feature: School Management
  As an administrator
  I want to register and manage schools in the system
  So that students and teachers have a structured environment

  Scenario: Registering a new school successfully
    Given I visit the home page
    When I click the "Add School" link
    And I fill in "school_name" with "St. Xavier Academy"
    And I fill in "school_code" with "SXA-10"
    And I fill in "school_address" with "123 High Street"
    And I click the "Create School" button
    Then I should see "School successfully created."
    And I should see "St. Xavier Academy"
    And I should see "SXA-10"

  Scenario: Validating required fields when creating a school
    Given I visit the new school page
    When I click the "Create School" button
    Then I should see "Please correct the following errors"
