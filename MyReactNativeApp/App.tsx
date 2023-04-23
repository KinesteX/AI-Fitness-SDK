import React, { useState } from 'react';
import { Button, SafeAreaView, StyleSheet } from 'react-native';
import WebView from 'react-native-webview';

const App = () => {
  const [showWebView, setShowWebView] = useState(false);

  const toggleWebView = () => {
    setShowWebView(!showWebView);
  };

  return (
    <SafeAreaView style={styles.container}>
      {!showWebView && (
        <Button title="Open WebView" onPress={toggleWebView} />
      )}
      {showWebView && (
        <WebView
          source={{ uri: 'https://kineste-x-w.vercel.app' }}
          style={styles.webView}
          allowsFullscreenVideo={true}
          mediaPlaybackRequiresUserAction={false}
          onMessage={(event) => {
            if (event.nativeEvent.data === 'close') {
              toggleWebView();
            }
          }}
          javaScriptEnabled={true}
          mixedContentMode="always"
          allowFileAccessFromFileURLs={true}
          allowUniversalAccessFromFileURLs={true}
          allowsInlineMediaPlayback={true}
          geolocationEnabled={true}
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  webView: {
    flex: 1,
  },
});

export default App;
