# Maple Wallet

[![CI](https://github.com/jamierowe15/maple-wallet/actions/workflows/ci.yml/badge.svg)](https://github.com/jamierowe15/maple-wallet/actions/workflows/ci.yml)

A fictional mobile banking app in SwiftUI, built over five days as an iOS proficiency lab.
Swift 6 strict concurrency, MVVM, modular SPM packages.

> Work in progress. Day-by-day pull requests show how it was built.

## Run it (on a Mac)
```bash
brew install xcodegen
xcodegen generate
open MapleWallet.xcodeproj
```

## Run the logic tests (Mac, Linux or Windows)
```bash
cd Packages/Accounts && swift test
```
