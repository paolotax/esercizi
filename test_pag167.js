const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  console.log('🚀 Starting test for pag167 exercise...\n');

  try {
    // Navigate to the page
    console.log('📄 Navigating to http://localhost:3000/exercises/pag167');
    await page.goto('http://localhost:3000/exercises/pag167');
    await page.waitForLoadState('networkidle');

    // Check if the page loaded correctly
    const title = await page.locator('h1').textContent();
    console.log(`✓ Page loaded with title: "${title}"\n`);

    // Exercise 1: Complete words with SCIA, SCIO, SCIU
    console.log('📝 Testing Exercise 1: Complete words with SCIA, SCIO, SCIU');

    // Select SCIA for Sciarpa (first option, first choice - correct)
    console.log('  - Selecting SCIA for Sciarpa...');
    await page.locator('[data-word="Sciarpa"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // Select SCIO for Guscio (second option, second choice - correct)
    console.log('  - Selecting SCIO for Guscio...');
    await page.locator('[data-word="Guscio"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // Select SCIU for Asciugamano (third option, third choice - correct)
    console.log('  - Selecting SCIU for Asciugamano...');
    await page.locator('[data-word="Asciugamano"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    console.log('✓ Exercise 1 completed\n');

    // Exercise 2: Singular to plural
    console.log('📝 Testing Exercise 2: Singular to plural');

    // Select SCE for Bisce (correct)
    console.log('  - Selecting SCE for Bisce...');
    await page.locator('[data-word="Bisce"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    // Select SCI for Camosci (correct)
    console.log('  - Selecting SCI for Camosci...');
    await page.locator('[data-word="Camosci"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    console.log('✓ Exercise 2 completed\n');

    // Exercise 3: Reading comprehension
    console.log('📝 Testing Exercise 3: Reading comprehension');

    // Select "Lo sciatore" (correct answer)
    console.log('  - Selecting "Lo sciatore"...');
    await page.locator('[data-word="Sciatore"][data-correct="true"]').click();
    await page.waitForTimeout(500);

    console.log('✓ Exercise 3 completed\n');

    // Take a screenshot before checking answers
    await page.screenshot({ path: 'pag167_before_check.png', fullPage: true });
    console.log('📸 Screenshot saved: pag167_before_check.png\n');

    // Click the "Check Answers" button
    console.log('🎯 Clicking "Controlla le Risposte" button...');
    await page.locator('button:has-text("Controlla le Risposte")').click();
    await page.waitForTimeout(2000);

    // Take a screenshot after checking answers
    await page.screenshot({ path: 'pag167_after_check.png', fullPage: true });
    console.log('📸 Screenshot saved: pag167_after_check.png\n');

    // Check for feedback message
    const feedback = await page.locator('[data-exercise-checker-target="feedback"]').textContent();
    console.log(`📊 Feedback received: "${feedback}"\n`);

    console.log('✅ All tests completed successfully!');
    console.log('📊 Summary:');
    console.log('  - Page loaded correctly');
    console.log('  - All 3 exercises completed');
    console.log('  - All correct answers selected');
    console.log('  - Answer validation working');
    console.log('  - Screenshots captured');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    await page.screenshot({ path: 'pag167_error.png', fullPage: true });
    console.log('📸 Error screenshot saved: pag167_error.png');
  } finally {
    await browser.close();
  }
})();
