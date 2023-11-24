# SecureDiaLog Diabetes Monitoring Application

**An ANU Software Innovation Institute demo project for Solid PODs**.

*Authors: Ye Duan, Graham Williams, Bowen Yang*

*[ANU Software Innovation Institute](https://sii.anu.edu.au)*

*License: GNU GPL V3*

Data is at the heart of managing our lives these days. But for too
long it has been collected centrally. It does not need to be! Using
the Solid Server standards we can now store our data in personal
online data stores, or PODs. Through the research of the ANU's
Software Innovation Institute, our PODs data is also encrypted on
server and only ever decrypted on device, protecting the data against
unwanted breeches, and implementing a **Trust No One** (TNO) platform.

This project is a privacy oriented diabetes data collection and
analysis application that runs on any of ios, android, windows, linux,
macos, or through a browser. 

The demonstrator application uses standards based Solid servers to
help individuals manage their diabetes.

## Introduction

This software engineering and artefact-oriented development-based
project delivers a location-aware and data recording app. Flutter/Dart
are used for the front end with Solid server technology for the
backend to store data in a privacy focussed way. The app can actively
collect location pings regularly, allow the input of location based
observations, and provide graphical analyses of the collected data.

## The App

The application records users' personal data through a daily
questionnaire.  The historical data is displayed in real-time charts
and stored encrypted in a Solid POD. Users have complete control over
their data, including sharing the data with other POD users. With an
open format for storing the data, anyone can develop an app to add
value to the data, or to collect and store even more data.  The
current app also provides analytics based on the historical data to
assess and improve the diabetes status of the users.

### App Startup

On starting up the app you will see the login screen where a user's
WebID is to be entered. It will be remembered for future app
activity. To obtain a WebID for yourself, visit
https://solidcommunity.net/register. On clicking the Login button your
browser will popup to authenticate you on the Solid server, not on the
device. The device does not get to know your login details.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/login.png"
	alt="Login Screen" width="400">
</div>

### App Encryption Key

On successfully authenticating you, the app will ask you for your
encryption key. This is used to encrypt your data on device before
storing it into your POD on the remote Solid server. It is also used
to decrypt your data once it is loaded into your app from your POD on
the remote Solid server. The data is never decrypted on the remote
Solid server.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/encrypt.png"
	alt="Encrypt Screen" width="400">
</div>

### App Home Screen

That then brings us to the app's home screen from where you can
navigate to complete a survey, view the analysis charts, review the
actual data collected, visit your location, or update your app
settings.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/home.png"
	alt="Home Screen" width="400">
</div>

### App Survey Screen

Users can easily input various health metrics, including [specific metrics e.g., 
heart rate, blood glucose, etc.], along with the date and time of recording. The app 
allows submission of multiple surveys per day, catering to the need for tracking 
varying health parameters throughout the day.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/survey.PNG"
	alt="Survey Screen" width="400">
</div>

### App Charts Screen

Displays the latest 15 days of health data in an easy-to-understand chart format. 
Highlights the highest recorded metric of each day and provides additional details 
via a tooltip view. Offers the functionality to refresh data following modifications 
in the POD.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/charts.PNG"
	alt="Charts Screen" width="400">
</div>

### App Data Screen

Users can view all personal health data stored in the POD. Features include the 
ability to delete data, export data to CSV via the internet, and import data 
from the user's device.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/data.PNG"
	alt="Data Screen" width="400">
</div>

### App Map Screen

Visual representation of location information, enhancing the context of health data.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/map.PNG"
	alt="Map Screen" width="400">
</div>

### App Settings Screen

Users can record their encryption key and WebID on their devices. Options to hide 
location data and adjust the frequency of location capturing. Displays the time 
of the last completed survey. Secure and easy logout process.

<div align="center">
	<img
	src="https://github.com/kimishidairessha/secureDiaLog/blob/main/images/settings.PNG"
	alt="Settings Screen" width="400">
</div>

## Features

* Data storage is private to the user
* Data on the server is encrypted

* Daily questionnaires for data collection
* Real-time chart visualizations
* Complete user data control
* Diabetes status analytics

## Credits

Bowen Wang began this as a student project based on Graham Williams'
design and supervision. See https://github.com/onionoino/klee. Ye Duan
continued its development as a student project and migrated the
original concept into a daily diabetes survey capturing app under
Graham Williams' supervision.
