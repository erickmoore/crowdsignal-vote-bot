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
    headless: true, // set to false to see browser and test if script works
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu' 
    ]
  });

  let successfulVotes = 0;
  const maxRetries = 3;

  for (let i = 0; i < 20; i++) {
    let page = null;
    let voteSuccessful = false;
    
    for (let retry = 0; retry < maxRetries && !voteSuccessful; retry++) {
      try {
        page = await browser.newPage();
        console.log(`Vote ${i + 1} of 20 (attempt ${retry + 1}/${maxRetries})`);
        
        // Set timeout for page navigation
        await page.goto(POLL_URL, { waitUntil: 'networkidle2', timeout: 30000 });

        await page.evaluate((answerId) => {
          const element = document.querySelector(`#${answerId}`);
          if (!element) {
            throw new Error(`Element with ID ${answerId} not found`);
          }
          element.click();
          
          const voteButton = document.querySelector(".pds-vote-button");
          if (!voteButton) {
            throw new Error("Vote button not found");
          }
          voteButton.click();
        }, PDI_ANSWER);

        // Wait a bit to ensure vote is registered
        await page.waitForTimeout(2000);
        
        const cookies = await page.cookies();
        await page.deleteCookie(...cookies);
        await page.close();
        page = null;
        
        voteSuccessful = true;
        successfulVotes++;
        console.log(`✓ Vote ${i + 1} successful`);
        
      } catch (error) {
        console.error(`✗ Vote ${i + 1} attempt ${retry + 1} failed:`, error.message);
        
        if (page) {
          try {
            await page.close();
          } catch (closeError) {
            console.error('Error closing page:', closeError.message);
          }
          page = null;
        }
        
        // Wait before retry
        if (retry < maxRetries - 1) {
          console.log(`Retrying in 3 seconds...`);
          await new Promise(resolve => setTimeout(resolve, 3000));
        }
      }
    }
    
    if (!voteSuccessful) {
      console.error(`✗ Vote ${i + 1} failed after ${maxRetries} attempts, continuing...`);
    }
  }

  console.log(`Voting batch completed: ${successfulVotes}/20 successful votes`);
  await browser.close();
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
  try {
    console.log("Voting batch running");
    await runVotes();
    console.log("Voting batch completed successfully");
  } catch (error) {
    console.error("Critical error in voting batch:", error.message);
    console.log("Continuing with next batch...");
  }
  
  const sleepTime = Math.floor(Math.random() * 20 + 60);
  sleep(sleepTime);
}
