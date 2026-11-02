const { BeforeAll, AfterAll, Before, After, setDefaultTimeout } = require('@cucumber/cucumber');
const { chromium } = require('playwright');
const { spawn, execSync } = require('child_process');
const http = require('http');

setDefaultTimeout(60000);

let serverProcess = null;
let browser = null;
const SERVER_PORT = 3001;
const BASE_URL = `http://127.0.0.1:${SERVER_PORT}`;

function isServerHealthy() {
  return new Promise((resolve) => {
    const req = http.get(`${BASE_URL}/up`, (res) => {
      resolve(res.statusCode === 200);
    });
    req.on('error', () => resolve(false));
    req.setTimeout(1000, () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function waitForServerToStart(maxAttempts = 30) {
  for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
    const healthy = await isServerHealthy();
    if (healthy) {
      return true;
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  throw new Error('Rails test server failed to start within timeout');
}

function startRailsTestServer() {
  const env = {
    ...process.env,
    RAILS_ENV: 'test',
    PORT: String(SERVER_PORT),
    PATH: `/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:${process.env.PATH}`
  };

  serverProcess = spawn('bin/rails', ['server', '-e', 'test', '-p', String(SERVER_PORT)], {
    env,
    stdio: 'ignore'
  });
}

function stopRailsTestServer() {
  if (serverProcess && !serverProcess.killed) {
    serverProcess.kill('SIGTERM');
  }
}

function cleanDatabase() {
  const env = {
    ...process.env,
    PATH: `/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:${process.env.PATH}`
  };
  execSync('bin/rails runner -e test "School.destroy_all"', { env, stdio: 'ignore' });
}

BeforeAll(async () => {
  const healthy = await isServerHealthy();
  if (!healthy) {
    startRailsTestServer();
    await waitForServerToStart();
  }
  browser = await chromium.launch({ headless: true });
});

AfterAll(async () => {
  if (browser) {
    await browser.close();
  }
  stopRailsTestServer();
});

Before(async function () {
  cleanDatabase();
  this.baseUrl = BASE_URL;
  this.context = await browser.newContext();
  this.page = await this.context.newPage();
});

After(async function () {
  if (this.page) {
    await this.page.close();
  }
  if (this.context) {
    await this.context.close();
  }
});
