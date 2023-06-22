import React, { useState, useEffect } from 'react';

const App = () => {
  const [showWebView, setShowWebView] = useState(false);
  const toggleWebView = () => setShowWebView(!showWebView);

  const userId = '123abcd';
  const age = 25;
  const gender = 'male';
  const weight = 70;
  const sub_category = 'Stay%20Fit';
  const category = 'Fitness';

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


  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
      }}
    >
      {!showWebView && (
        <button
          style={{
            padding: '20px 40px',
            fontSize: '24px',
            backgroundColor: '#000000',
            color: '#ffffff',
            border: 'none',
            borderRadius: '10px',
            cursor: 'pointer',
            position: 'fixed',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            zIndex: '1',
          }}
          onClick={toggleWebView}
        >
          Open WebView
        </button>
      )}
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
            src={`https://kineste-x-w.vercel.app?userId=${userId}&age=${age}&gender=${gender}&weight=${weight}&sub_category=${sub_category}&category=${category}`}
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
    </div>
  );
};

export default App;
