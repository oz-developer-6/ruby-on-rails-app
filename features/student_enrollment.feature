Feature: Student Enrollment
  As a school administrator
  I want to enroll students into schools
  So that their academic homework can be tracked

  Background:
    Given a school exists named "Pinecrest High" with code "PCH-01"

  Scenario: Enrolling a student into a school
    Given I visit the students page
    When I click the "Enroll Student" link
    And I select "Pinecrest High" from "student_school_id"
    And I fill in "student_first_name" with "Eleanor"
    And I fill in "student_last_name" with "Rigby"
    And I fill in "student_email" with "eleanor@pinecrest.edu"
    And I fill in "student_enrollment_number" with "PCH-2026-001"
    And I click the "Create Student" button
    Then I should see "Student successfully enrolled."
    And I should see "Eleanor Rigby"
    And I should see "PCH-2026-001"
