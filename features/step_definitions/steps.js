const { Given, When, Then } = require('@cucumber/cucumber');
const { execSync } = require('child_process');

function executeRailsCommand(commandCode) {
  const env = {
    ...process.env,
    PATH: `/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:${process.env.PATH}`
  };
  const sanitized = commandCode.replace(/"/g, '\\"');
  execSync(`bin/rails runner -e test "${sanitized}"`, { env, stdio: 'pipe' });
}

Given('I visit the home page', async function () {
  await this.page.goto(`${this.baseUrl}/`);
});

Given('I visit the new school page', async function () {
  await this.page.goto(`${this.baseUrl}/schools/new`);
});

Given('I visit the students page', async function () {
  await this.page.goto(`${this.baseUrl}/students`);
});

Given('I visit the homeworks page', async function () {
  await this.page.goto(`${this.baseUrl}/homeworks`);
});

Given('a school exists named {string} with code {string}', function (schoolName, schoolCode) {
  executeRailsCommand(`School.create!(name: '${schoolName}', code: '${schoolCode}')`);
});

Given('a student exists named {string} with email {string} and enrollment {string} in {string}', function (studentFullName, studentEmail, enrollmentNumber, schoolName) {
  const nameSegments = studentFullName.split(' ');
  const firstName = nameSegments[0];
  const lastName = nameSegments.slice(1).join(' ');
  executeRailsCommand(`school = School.find_by!(name: '${schoolName}'); Student.create!(school: school, first_name: '${firstName}', last_name: '${lastName}', email: '${studentEmail}', enrollment_number: '${enrollmentNumber}')`);
});

Given('a homework exists titled {string} with max score {int} in {string}', function (homeworkTitle, maxScore, schoolName) {
  executeRailsCommand(`school = School.find_by!(name: '${schoolName}'); Homework.create!(school: school, title: '${homeworkTitle}', subject: 'General', max_score: ${maxScore}, due_date: Date.tomorrow)`);
});

Given('the homework {string} is assigned to {string}', function (homeworkTitle, studentFullName) {
  const nameSegments = studentFullName.split(' ');
  const firstName = nameSegments[0];
  const lastName = nameSegments.slice(1).join(' ');
  executeRailsCommand(`homework = Homework.find_by!(title: '${homeworkTitle}'); student = Student.find_by!(first_name: '${firstName}', last_name: '${lastName}'); Marking.create!(homework: homework, student: student, status: 'pending')`);
});

When('I click the {string} link', async function (linkText) {
  const link = this.page.getByRole('link', { name: linkText, exact: true }).first();
  await link.click();
});

When('I click the {string} button', async function (buttonText) {
  const button = this.page.getByRole('button', { name: buttonText, exact: true }).first();
  await button.click();
});

When('I click the {string} link for {string}', async function (actionText, rowText) {
  const tableRow = this.page.locator('tr', { hasText: rowText });
  await tableRow.getByRole('link', { name: actionText, exact: true }).first().click();
});

When('I fill in {string} with {string}', async function (elementId, inputValue) {
  await this.page.locator(`#${elementId}`).fill(inputValue);
});

When('I select {string} from {string}', async function (optionLabel, selectId) {
  await this.page.locator(`#${selectId}`).selectOption({ label: optionLabel });
});

Then('I should see {string}', async function (expectedContent) {
  await this.page.waitForSelector(`text=${expectedContent}`, { timeout: 5000 });
});

Then('I should not see {string}', async function (unexpectedContent) {
  const pageBodyText = await this.page.textContent('body');
  if (pageBodyText.includes(unexpectedContent)) {
    throw new Error(`Expected page not to include "${unexpectedContent}"`);
  }
});
