use tracing::{info, Level};

fn main() {
  tracing_subscriber::fmt().with_max_level(Level::INFO).init();
  info!("Hello, world!");
}
