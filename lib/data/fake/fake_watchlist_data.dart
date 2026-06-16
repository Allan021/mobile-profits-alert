import '../../domain/entities/ticker.dart';

final List<Ticker> fakeWatchlist = [
  const Ticker(symbol: 'MSFT', companyName: 'Microsoft Corporation', sentimentScore: 2.4, trend: TickerTrend.up),
  const Ticker(symbol: 'GOOGL', companyName: 'Alphabet Inc.', sentimentScore: -0.1, trend: TickerTrend.flat),
  const Ticker(symbol: 'NVDA', companyName: 'NVIDIA Corporation', sentimentScore: 5.2, trend: TickerTrend.up),
  const Ticker(symbol: 'TSLA', companyName: 'Tesla, Inc.', sentimentScore: -3.8, trend: TickerTrend.down),
];

final List<Ticker> fakeSearchResults = [
  const Ticker(symbol: 'AAPL', companyName: 'Apple Inc.', sentimentScore: 1.2, trend: TickerTrend.up),
  const Ticker(symbol: 'META', companyName: 'Meta Platforms, Inc.', sentimentScore: -2.1, trend: TickerTrend.down),
  const Ticker(symbol: 'AMZN', companyName: 'Amazon.com, Inc.', sentimentScore: 0.8, trend: TickerTrend.up),
  const Ticker(symbol: 'NFLX', companyName: 'Netflix, Inc.', sentimentScore: 3.1, trend: TickerTrend.up),
  const Ticker(symbol: 'AMD', companyName: 'Advanced Micro Devices', sentimentScore: 1.5, trend: TickerTrend.up),
  const Ticker(symbol: 'INTC', companyName: 'Intel Corporation', sentimentScore: -1.9, trend: TickerTrend.down),
  const Ticker(symbol: 'CRM', companyName: 'Salesforce, Inc.', sentimentScore: 0.3, trend: TickerTrend.flat),
  const Ticker(symbol: 'ORCL', companyName: 'Oracle Corporation', sentimentScore: 2.7, trend: TickerTrend.up),
];
