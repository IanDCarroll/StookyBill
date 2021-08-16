# Manual Testing

## Local Testing all-in-one machine

### Setup an Input Source

####  via Open Broadcast Software

  1. [Download and install OBS](https://obsproject.com/)
  1. [Run through OBS Setup](OBS_setup.md)

####  via Blackmagic Atem Mini

  1. [Get an Atem switcher](https://www.blackmagicdesign.com/products/atemmini)
  1. [Follow this guide](https://heretorecord.com/blog/custom-streaming-destination-atem-mini-pro
  )
  1. Replace their cutom URL with the one pointing to where StookyBill will be listening `rtmp://localhost:1935/secret_stream_key`

### Setup an Output Monitor

#### via VLC Media Player

  1. [Download and install VLC](https://www.videolan.org/)
  1. [Run through VLC Setup](VLC_setup.md)

### via web browser

  - coming soon, and may involve creating a frontend app for viewing the server's live output.

### Local Testing between remote machines

  - Coming soon, but will involve allowing permissions through your network router.

=> back to [README](../README.md)