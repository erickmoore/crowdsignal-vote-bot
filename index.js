import puppeteer from "puppeteer";

//find: PDI_answer65995131

const PDI_ANSWER = process.env.PDI_ANSWER;
const POLL_URL = process.env.POLL_URL;

if (!PDI_ANSWER) {
  console.error("Please provide the PDI_answer value as an environment variable.");
  process.exit(1);
}

if (!POLL_URL) {
  console.error("Please provide the POLL_URL value as an environment variable.");
  process.exit(1);
}

async function runVotes() {
  const browser = await puppeteer.launch({
    headless: false, // set to false to see browser and test if script works
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu' 
    ]
  });

  for (let i = 0; i < 20; i++) {
    const page = await browser.newPage();
    console.log(`Vote ${i + 1}  of 20`);
    await page.goto(POLL_URL);

    await page.evaluate((answerId) => {
      const element = document.querySelector(`#${answerId}`);
      if (!element) {
        throw new Error(`Element with ID ${answerId} not found`);
      }
      element.click();
      document.querySelector(".pds-vote-button").click();
    }, PDI_ANSWER);

    const cookies = await page.cookies();
    await page.deleteCookie(...cookies);
    await page.close();
  }

 browser.close();

}

function sleep(seconds) {
  console.log(`Sleeping for ${seconds} seconds...`);
  const date = Date.now();
  let currentDate = null;
  do {
    currentDate = Date.now();
  } while (currentDate - date < seconds * 1000);
}

while (true) {
  console.log("Voting batch running");
  await runVotes();
  sleep(Math.floor(Math.random() * 20 + 60));
}
