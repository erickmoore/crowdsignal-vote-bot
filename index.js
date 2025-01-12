import puppeteer from "puppeteer";

const browser = await puppeteer.launch({
  headless: true, // set to false to see browser and test if script works
  //args: ["--proxy-server=socks5://127.0.0.1:9050"],
});

async function runVotes() {
  for (let i = 0; i < 20; i++) {
    const page = await browser.newPage();
    await page.goto(`https://poll.fm/14875173/`);
    await page.evaluate(() => {
      document.querySelector("#PDI_answer65995133").click();
      document.querySelector(".pds-vote-button").click();
    });
    const cookies = await page.cookies();
    await page.deleteCookie(...cookies);
    await page.close();
  }
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
  sleep(Math.floor(Math.random() * 20 + 10));
}
