export {}

declare global {
  interface Window {
    translations?: Record<string, string>;
  }
}