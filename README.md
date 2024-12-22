# Work Log Fit

Work Log Fit is an application primarily designed for Android devices, although it should function on other platforms as well. It assists users in logging their weight training sessions at the gym. When I couldn't find an open-source application that met my requirements, I decided to learn Dart and Flutter to create my own. There is potential for code refinement, but the application remains straightforward in its current form.

This project is distributed under the MIT license.

# Warning

I did the main part of this application in one week, in my free time, and without any knowledge of flutter and dart.
So I did this to learn, and after one week, i can clearly see that it could be simpler.

# Everkinetic image

The Work Log Fit application enhances the user experience by incorporating visual representations of different exercises.
The images used for this purpose were originally obtained from the Everkinetic open data project, founded by Greg Priday. 
While the Everkinetic website is currently not accessible, the images remain an integral part of the application, showcasing various workout exercises.

# Generating Smaller Image Assets

This application requires smaller versions of all the images.
These can be generated using the `generate_assets_icons.sh` script.
To create the smaller image assets, navigate to the assets directory and execute the script as follows:

```bash
cd assets
bash generate_assets_icons.sh
```

