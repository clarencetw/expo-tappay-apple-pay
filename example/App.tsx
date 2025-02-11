import applePay from "expo-tappay-apple-pay";
import { useEffect } from "react";
import { Button, Platform, StyleSheet, View } from "react-native";

export default function App() {
  useEffect(() => {
    if (Platform.OS === "ios" && applePay.isApplePayAvailable()) {

      const primeSubscription = applePay.addReceivePrimeListener((event) => {
        console.log("Received prime event:", event);
        if (event.success) {
          console.log("Prime:", event.prime);
          console.log("Total Amount:", event.totalAmount);
          console.log("Client IP:", event.clientIP);
          applePay.showResult(true);
        } else {
          console.error("Failed to get prime:", event.message);
          applePay.showResult(false);
        }
      });

      const startSubscription = applePay.addApplePayStartListener((event) => {
        console.log("Apple Pay started:", event);
      });

      const cancelSubscription = applePay.addApplePayCancelListener((event) => {
        console.log("Apple Pay cancelled:", event);
      });

      return () => {
        applePay.removeListener(primeSubscription);
        applePay.removeListener(startSubscription);
        applePay.removeListener(cancelSubscription);
      };
    }
  }, []);

  const setupMerchant = async () => {
    try {
      await applePay.setupMerchant({
        name: "Tappay Test",
        capabilities: "3DS",
        merchantId: "merchant.tech.cherri.global.test",
        countryCode: "TW",
        currencyCode: "TWD",
      });
    } catch (error) {
      console.error("Setup merchant failed:", error);
    }
  };

  const showSetup = () => {
    applePay.showSetup();
  };

  const startPayment = async () => {
    try {
      await applePay.startPayment({
        cart: [
          {
            name: "Test",
            amount: 100,
          },
        ],
      });
    } catch (error) {
      console.error("Payment failed:", error);
    }
  };

  return (
    <View style={styles.container}>
      <Button title="Setup Merchant" onPress={setupMerchant} />
      <Button title="Show Setup" onPress={showSetup} />
      <Button title="Start Payment" onPress={startPayment} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
