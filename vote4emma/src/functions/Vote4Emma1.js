//const puppeteer = require('puppeteer');
const puppeteer = require('puppeteer-core');
const chromium = require('chrome-aws-lambda');
const { app } = require('@azure/functions');

if (!app) {
    console.error('Failed to load @azure/functions module');
    process.exit(1);
}

app.timer('Vote4Emma1', {
    schedule: '0 */5 * * * *',
    handler: async (myTimer, context) => {
        const browser = await puppeteer.launch({
            args: chromium.args,
            defaultViewport: chromium.defaultViewport,
            executablePath: await chromium.executablePath,
            headless: chromium.headless,
        });

        async function runVotes() {
            for (let i = 0; i < 20; i++) {
                const page = await browser.newPage();
                await page.goto('https://poll.fm/16001163/');
                await page.evaluate(() => {
                    document.querySelector('#PDI_answer65995133').click();
                    document.querySelector('.pds-vote-button').click();
                });
                context.log(`Vote ${i} complete`);
                const cookies = await browser.cookies();
                await browser.deleteCookie(...cookies);
                await page.close();
            }
        }

        try {
            await runVotes();
            console.log('Votes completed'); // Log when all votes are completed
        } catch (error) {
            console.error('Error running votes:', error); // Log any errors during voting
        } finally {
            if (browser) {
                await browser.close();
                console.log('Browser closed'); // Log when the browser is closed
            }
        }

    }
});

module.exports = app;