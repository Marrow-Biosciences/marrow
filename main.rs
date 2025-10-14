use tracing::{info, Level};

fn main() {
  tracing_subscriber::fmt().level(Level::INFO).init();
  info!("Hello, world!");
}
