const overrides = {
  wrapper: "cloudflare-node",
  converter: "edge",
  proxyExternalRequest: "fetch",
  incrementalCache: "dummy",
  tagCache: "dummy",
  queue: "direct"
};

const config = {
  default: { override: overrides },
  edgeExternals: ["node:crypto"],
  middleware: {
    external: true,
    override: {
      wrapper: "cloudflare-edge",
      converter: "edge",
      proxyExternalRequest: "fetch",
      incrementalCache: "dummy",
      tagCache: "dummy",
      queue: "direct"
    }
  }
};

export default config;
