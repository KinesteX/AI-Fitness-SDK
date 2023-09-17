
# README for Git

This guide will walk you through the installation and configuration of the WebView component for integrating KinesteX workouts into your app.

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
### Available categories to sort plans: 

The empty spaces in urls are formatted like this %20 so if you want to sort the plan based on the category copy the category as specified below

| **Plan Category** | 
| --- | 
| **Strength** | 
| **Weight%20Management** | 
| **Cardio** |
| **Rehabilitation** | 

### Available categories and sub categories to sort workouts: 

The empty spaces in urls are formatted like this %20 so if you want to sort the workout based on the sub_category copy the sub _category as specified below

| **Category** | **Sub-category** |
| --- | --- |
| **Fitness** | Stay%20Fit, Stretching, Cardio |
| **Rehabilitation** | Back%20Relief, Knee%20Therapy, Neck%20Relief |

## Available parameters:
```jsx
userId = "123abcd"; // Replace this with the actual user ID from your data source
age = 25; // Replace this with the actual age from your data source
gender = "male"; // Replace this with the actual gender from your data source
weight = 70; // Replace this with the actual weight from your data source
sub_category = "Stay%20Fit"; //The spaces in url values have to have "%20" in them (You can pass multiple sub categories, 
//sub_category = 'Stay%20Fit,Knee%20Therapy,Cardio' (They have to be separated by a comma without a space) 
category = "Fitness"; // You can only have one category
goals = "Weight Management"; // Replace this with the actual goal (COMING SOON)
// multiple goals ex:  goals = 'Weight Management, Mental Health'
```
### Handling responses from KinesteX:
Currently supported communication is via web postMessages. You can add a listener to the webview events. See specifications for your language below, but generally we let you know when user completes following events:

  ```jsx
    //finished the workout and now redirected to the all workouts section
    if (message.type === "finished_workout") {
      console.log("Received data:", message.data);
    /*
    Format of the Received data:
    {
    date = "2023-06-09T17:34:49.426Z";
    totalCalories = "0.96";
    totalRepeats = 3;
    totalSeconds = 18;
    userId = 123abcd;
    workout = "Fitness Lite";
    }
    */
    
    }
   
    if (message.type === "exitApp"){
      //clicked on exit, so handle the exit flow by removing WebView
      
    }
       if (message.type === "error_occured") {
       // saved workout data in case of an error that causes ui freeze
      console.log("Received data:", message.data);
     
    }
    if (message.type === "exercise_completed") {
      // (Optional)
      // saved exercise data in case you want to cache the data of each exercise
      console.log("Received data:", message.data);  
      /*
      Format:
      {
      exercise: "Overhead Arms Raise";
      repeats: 20;
      timeSpent: 30;
      calories: "5.0";
      }
      */

    }
```

------------------
## Usage React Progressive Web App:

Parameters:
```jsx
  const [showWebView, setShowWebView] = useState(false);
  const toggleWebView = () => setShowWebView(!showWebView);

 const userId = '123abcd'; // Replace this with the actual user ID from your data source
const age = 25; // Replace this with the actual age from your data source
const gender = 'male'; // Replace this with the actual gender from your data source
const weight = 70; // Replace this with the actual weight from your data source
const sub_category = 'Stay%20Fit'; //The spaces in url values have to have "%20" in them (You can pass multiple sub categories, 
//ex: sub_category = 'Stay%20Fit,Knee%20Therapy,Cardio' (They have to be separated by a comma without a space) 
const categoryWorkout = 'Fitness'; // You can only have one category
const planC = 'Strength'; // Category for the plan
const goals = 'Weight Management'; // Replace this with the actual goal (COMING SOON)
// multiple goals ex:  goals = 'Weight Management, Mental Health'
```

Handling postMessages from KinesteX:
```jsx
const handleMessage = (event) => {
    try {
      if (event.data) {
        const message = JSON.parse(event.data);
  
        console.log('Received data:', message); // Log the received data
  
        if (message.type === 'finished_workout') {
          console.log('Received data:', message.data);
          /*
          Format of the Received data:
          {
            date: "2023-06-09T17:34:49.426Z",
            totalCalories: "0.96",
            totalRepeats: 3,
            totalSeconds: 18,
            userId: "123abcd",
            workout: "Fitness Lite"
          }
          */
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
          /*
          Format:
          {
            exercise: "Overhead Arms Raise",
            repeats: 20,
            timeSpent: 30,
            calories: "5.0"
          }
          */
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
  }, [toggleWebView]); // <- Add toggleWebView here

```

Displaying KinesteX:
```jsx
   {showWebView && (
        <div
          style={{
            position: 'fixed',
            top: '0',
            left: '0',
            width: '100%',
            height: '100%',
            zIndex: '0',
          }}
        >
          <iframe
            src={`https://kineste-x-w.vercel.app?userId=${userId}&planC=${planC}&age=${age}&gender=${gender}&weight=${weight}&sub_category=${sub_category}&category=${categoryWorkout}`}
            frameBorder="0"
            allow="camera; microphone; autoplay"
            sandbox="allow-same-origin allow-scripts"
            allowFullScreen={true}
            style={{
              width: '100%',
              height: '100%',
            }}
          ></iframe>
        </div>
      )}
```

See PWA-KinesteX for a demo code

------------------
