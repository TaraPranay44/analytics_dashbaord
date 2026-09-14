const AVATAR_GRADIENTS: ReadonlyArray<readonly [string, string]> = [
  ["#6C5CE7", "#FF5FB8"],
  ["#00D9B5", "#6C5CE7"],
  ["#FF7A85", "#FFB020"],
  ["#8A6BFF", "#FF5FB8"],
  ["#FFB020", "#FF5FB8"],
];

/** "Maya Chatterjee" -> "MC". Falls back to "?" for an empty name. */
export function initialsFor(name: string): string {
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return parts.map((part) => part[0]?.toUpperCase() ?? "").join("") || "?";
}

/** Deterministic gradient from a stable id/name, so the same person's avatar looks the same everywhere. */
export function avatarGradientFor(seed: string): string {
  let hash = 0;
  for (const char of seed) hash = (hash * 31 + char.charCodeAt(0)) | 0;
  const [from, to] = AVATAR_GRADIENTS[Math.abs(hash) % AVATAR_GRADIENTS.length];
  return `linear-gradient(135deg, ${from}, ${to})`;
}
