Feature: Homework and Marking Workflow
  As a teacher
  I want to create homework, assign it to students, and grade submissions
  So that students receive marks and feedback on their work

  Background:
    Given a school exists named "Westfield High" with code "WFH-01"
    And a student exists named "Lucas Scott" with email "lucas@westfield.edu" and enrollment "WFH-001" in "Westfield High"
    And a student exists named "Nathan Scott" with email "nathan@westfield.edu" and enrollment "WFH-002" in "Westfield High"

  Scenario: Publishing homework and assigning it to all students
    Given I visit the homeworks page
    When I click the "Create Homework" link
    And I select "Westfield High" from "homework_school_id"
    And I fill in "homework_title" with "Linear Algebra Problem Set"
    And I fill in "homework_subject" with "Mathematics"
    And I fill in "homework_description" with "Solve problems 1 to 10 on page 45"
    And I fill in "homework_max_score" with "100"
    And I fill in "homework_due_date" with "2026-12-15"
    And I click the "Create Homework" button
    Then I should see "Homework assignment successfully published."
    When I click the "Assign to All Students" button
    Then I should see "Homework successfully assigned to all students"
    And I should see "Lucas Scott"
    And I should see "Nathan Scott"

  Scenario: Grading a student homework submission
    Given a homework exists titled "History Essay" with max score 100 in "Westfield High"
    And the homework "History Essay" is assigned to "Lucas Scott"
    When I visit the homeworks page
    And I click the "History Essay" link
    And I click the "Grade" link for "Lucas Scott"
    And I select "Marked" from "marking_status"
    And I fill in "marking_score" with "92"
    And I fill in "marking_feedback" with "Excellent analysis of primary sources"
    And I click the "Save Marking" button
    Then I should see "Marking successfully recorded."
    And I should see "92"
    And I should see "A"
    And I should see "Excellent analysis of primary sources"
