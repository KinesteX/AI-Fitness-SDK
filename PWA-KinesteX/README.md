
This guide will walk you through the installation and configuration of the WebView component for integrating KinesteX plans and workouts into your app.

## Configuration

#### AndroidManifest.xml

Add the following permissions for camera and microphone usage:

```xml
<!-- Add this line inside the <manifest> tag -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIDEO_CAPTURE" />

```

#### Info.plist

Add the following keys for camera and microphone usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>
```

### Available categories to sort plans (param key is planC): 

| **Plan Category (key: planC)** | 
| --- | 
| **Strength** | 
| **Cardio** |
| **Rehabilitation** | 


### Available categories and sub categories to sort workouts: 

| **Category (key: category)** | **Sub-category (key: sub_category)** |
| --- | --- |
| **Fitness** | Stay Fit, Stretching, Cardio |
| **Rehabilitation** | Back Relief, Knee Therapy, Neck Relief |


## Available parameters:
```jsx
  const postData = {
// REQUIRED
    userId: 'YOUR USER ID',
    company: 'YOUR COMPANY', // contact KinesteX
    key: 'YOUR KEY', // contact KinesteX
// OPTIONAL
    category: 'Fitness',
    planC: 'Cardio',
    age: 50,
    height: 150, // in cm
    weight: 200,
    gender: 'Male'
  };
```
### Communicating with KinesteX:
Currently supported communication is via HTTP postMessages. 

When presenting iframe, share the data in the following way: 

```jsx
  useEffect(() => {
    if (showWebView && iframeRef.current) {
      // Ensure the iframe is loaded before posting the message
      iframeRef.current.onload = () => {
        iframeRef.current.contentWindow.postMessage(postData, '*'); // Current post message source target, we will make it more secure later
      };
    }
  }, [showWebView]);

```


To listen to user events: 

  ```jsx
  const handleMessage = (event) => {
    
    try {
      if (event.data) {
        const message = JSON.parse(event.data);
  
        console.log('Received data:', message); // Log the received data
  
        if (message.type === 'finished_workout') {
          console.log('Received data:', message.data);
     
        }
        if (message.type === 'exitApp') {
          toggleWebView();
        }
        if (message.type === 'error_occured') {
          console.log('Received data:', message.data);
          toggleWebView();
        }
        if (message.type === 'exercise_completed') {
          console.log('Received data:', message.data);
      
        }
      } else {
        console.log('Received empty message'); // Log if the message is empty
      }
    } catch (e) {
      console.error('Could not parse JSON message from WebView:', e);
    }
  };
  useEffect(() => {
    const handleWindowMessage = (event) => {
      handleMessage(event);
    };

    window.addEventListener('message', handleWindowMessage);

    return () => {
      window.removeEventListener('message', handleWindowMessage);
    };
  }, [toggleWebView]); 

```
 **Message Types in handleMessage function**:
    The core of the `handleMessage` function is a switch statement that checks the `type` property of the parsed message. Each case corresponds to a different type of action or event that occurred in the KinesteX SDK.
    
   - `kinestex_launched`: Logs when the KinesteX SDK is successfully launched.
   - `workout_opened`: Logs when a workout is opened.
   - `workout_started`: Logs when a workout is started.
   - `plan_unlocked`: Logs when a user unlocks a plan.
   - `finished_workout`: Logs when a workout is finished.
  - `error_occured`: Logs when there's an error. (Coming soon)
   - `exercise_completed`: Logs when an exercise is completed.
  - `exitApp`: Logs when user clicks on exit button, triggering an exit message. The iframe should be hidden if this message is sent

------------------

## Displaying KinesteX through iframe:
```jsx
return (
    <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
      {!showWebView && <button onClick={toggleWebView}>Open WebView</button>} {/* CUSTOM BUTTON TO LAUNCH KINESTEX */}
      {showWebView && (
        <div style={{ position: 'fixed', top: '0', left: '0', width: '100%', height: '100%', zIndex: '0' }}>
          <iframe
            ref={iframeRef}
            src="https://kinestex-sdk-git-redesign-v-m1r.vercel.app/"
            frameBorder="0"
            allow="camera; microphone; autoplay"
            sandbox="allow-same-origin allow-scripts"
            allowFullScreen={true}
            javaScriptEnabled={true}
            style={{ width: '100%', height: '100%' }}
          ></iframe>
        </div>
      )}
    </div>
  );

```
See PWA-KinesteX for a demo code

------------------
