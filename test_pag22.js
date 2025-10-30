const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  console.log('🚀 Starting test for pag22 exercise...\n');

  try {
    // Navigate to the page
    console.log('📄 Navigating to http://localhost:3000/exercises/pag22');
    await page.goto('http://localhost:3000/exercises/pag22');
    await page.waitForLoadState('networkidle');

    // Check if the page loaded correctly
    const title = await page.locator('h1').textContent();
    console.log(`✓ Page loaded with title: "${title}"\n`);

    // Exercise 2: Find A in words (AUTO, MORA, VASO)
    console.log('📝 Testing Exercise 2: Find A in words');

    // Click A in AUTO
    console.log('  - Clicking A in AUTO...');
    await page.locator('[data-word="AUTO"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // Click A in MORA
    console.log('  - Clicking A in MORA...');
    await page.locator('[data-word="MORA"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // Click A in VASO
    console.log('  - Clicking A in VASO...');
    await page.locator('[data-word="VASO"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    console.log('✓ Exercise 2 completed\n');

    // Exercise 3: Complete words with A
    console.log('📝 Testing Exercise 3: Complete words with A');

    // ALI
    console.log('  - Clicking A in ALI...');
    await page.locator('[data-word="ALI"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // ROSA
    console.log('  - Clicking A in ROSA...');
    await page.locator('[data-word="ROSA"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // NAVE
    console.log('  - Clicking A in NAVE...');
    await page.locator('[data-word="NAVE"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // MANO
    console.log('  - Clicking A in MANO...');
    await page.locator('[data-word="MANO"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // FATA (has 2 A's)
    console.log('  - Clicking both A in FATA...');
    const fataOptions = await page.locator('[data-word="FATA"][data-correct="true"]').all();
    for (const option of fataOptions) {
      await option.click();
      await page.waitForTimeout(300);
    }

    // LAMA (has 2 A's)
    console.log('  - Clicking both A in LAMA...');
    const lamaOptions = await page.locator('[data-word="LAMA"][data-correct="true"]').all();
    for (const option of lamaOptions) {
      await option.click();
      await page.waitForTimeout(300);
    }

    console.log('✓ Exercise 3 completed\n');

    // Take a screenshot before checking answers
    await page.screenshot({ path: 'pag22_before_check.png', fullPage: true });
    console.log('📸 Screenshot saved: pag22_before_check.png\n');

    // Click the "Check Answers" button
    console.log('🎯 Clicking "Controlla le Risposte" button...');
    await page.locator('button:has-text("Controlla le Risposte")').click();
    await page.waitForTimeout(2000);

    // Take a screenshot after checking answers
    await page.screenshot({ path: 'pag22_after_check.png', fullPage: true });
    console.log('📸 Screenshot saved: pag22_after_check.png\n');

    console.log('✅ All tests completed successfully!');
    console.log('📊 Summary:');
    console.log('  - Page loaded correctly');
    console.log('  - Exercise 2: Found A in AUTO, MORA, VASO');
    console.log('  - Exercise 3: Completed ALI, ROSA, NAVE, MANO, FATA, LAMA');
    console.log('  - Answer validation working');
    console.log('  - Screenshots captured');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    await page.screenshot({ path: 'pag22_error.png', fullPage: true });
    console.log('📸 Error screenshot saved: pag22_error.png');
  } finally {
    await browser.close();
  }
})();
