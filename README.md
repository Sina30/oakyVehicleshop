<img src="https://oaky.dev/vehicleshop2.png">

# oakyVehicleshop
This resource is based on the esx framework and works with ESX 1.2 & legacy. The script has a nice and clean ui which can be changed in the css. 


# Setup the script

1. Run the provided sql.
2. Drag & Drop the script into your server.
3. Restart your server or refresh your resources.
4. Setup the config

# Features
* Add as many vehicle shops as you want
* Clean & Unique UI Design
* Sell your vehicles you've bought from one of your shops
* Search for vehicles
* Percentage from the original price if you sell your vehicle

# FAQ
## How to change the price the player gets back when he sells the vehicle?
Open <code>server.lua</code> go to line <code>257</code> and change <b>0.40</b> to the value of your choice.

## How to change the ped?
Open <code>client.lua</code> go to line <code>53</code> and change the ped model to a model of your choice.

## I want to be able to sell any vehicle in the marker. How can I do that?
There are several ways how you can do this. One of these ways is the following:<br>
<b>client.lua - Line 46 - 71</b><br>
<i>Replace the function to the following:</i><br>
<code>
 function isValidModel(model)
  return true 
 end
</code>

## Can you convert this to a other framework?
Lets say... No. Do it yourself. Its not a big script.

## Support
If you encountered any issues with the script either open a issue ticket or create a ticket on my discord. We are happy to help you to resolve this issue!
Discord: https://dsc.gg/oaky
