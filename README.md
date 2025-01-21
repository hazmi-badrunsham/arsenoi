# US Stock Tracker App

## Overview

A Flutter-based app to track and analyze US stock data using **Finnhub** and **Polygon.io APIs**. Get real-time stock prices, technical indicators (RSI, Moving Averages, ATR), and buy/sell/hold signals.

## Features

- **Stock Search**: Fetch real-time stock data by entering stock symbols.
- **Trending Stocks**: View top trending stocks based on price change.
- **Community Suggestions**: Get stock recommendations based on technical analysis (RSI, MA, ATR).

## Setup

1. Clone the repo:

    ```bash
    git clone https://github.com/your-username/us-stock-tracker-app.git
    cd us-stock-tracker-app
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Replace API keys in `lib/community_suggestions_page.dart`:

    ```dart
    final apiKey = 'YOUR_POLYGON_API_KEY';
    final apiKey = 'YOUR_FINNHUB_API_KEY';
    ```

4. Run the app:

    ```bash
    flutter run
    ```

## How It Works

- **RSI**: Indicates overbought/oversold conditions.
- **Moving Averages**: Buy/sell signals based on short and long-term moving averages.
- **ATR**: Measures stock volatility.

