import com.paypal.selion.annotations.WebTest;
import com.paypal.selion.platform.grid.Grid;

import org.testng.annotations.Test;

import static org.testng.Assert.assertTrue;

public class SimpleTest {
  @Test
  @WebTest(additionalCapabilities="marionette:false")
  public void openWikipedia () {
    Grid.driver().get("http://www.wikipedia.org");
    assertTrue(Grid.driver().getTitle().contains("Wikipedia"));
  }
}
