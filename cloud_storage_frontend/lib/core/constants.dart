class Constants {
  static const String pinataJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJhNjEzNDFiNS1mNDc4LTRiNWYtYjNiNS05OGI0MjdhN2VmMTgiLCJlbWFpbCI6ImFsaWFzZ2hhcmlubm9jZW50QHlhaG9vLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI5YTU3NTQyZjJkYTI5ZDU2OTI3OCIsInNjb3BlZEtleVNlY3JldCI6IjFjMTU4YWNjMDVjMzIzMGVkMDg4NTZmZmE0OGNmMmIwNzI4NzI5NzFhMDU3ZjBkYTAwNzE1YWMwZTBkZmFmODciLCJleHAiOjE4MTgzNzQyODB9.FirfDasrHJsuwzpt4rIgp8Ik8r-STBeGXv6vsnEnOX4';
  
  // ⚠️  PHYSICAL DEVICE: Replace 127.0.0.1 with your Mac's LAN IP.
  //     Run `ifconfig | grep "inet "` on your Mac to find it (e.g. 192.168.1.42).
  //     127.0.0.1 only works in the iOS Simulator.
  static const String rpcUrl = 'http://127.0.0.1:8545'; // <-- change for physical iPhone
  static const int chainId = 31337;
  // ⚠️  TODO: Replace with your deployed contract address after running:
  //     npx hardhat run scripts/deploy.js --network localhost
  static const String contractAddress = 'YOUR_CONTRACT_ADDRESS_HERE';

  // Secure Storage Keys
  static const String privateKeyStorageKey = 'wallet_private_key';
}
