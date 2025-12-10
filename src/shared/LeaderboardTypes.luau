-- Leaderboard type definitions

export type LeaderboardEntry = {
	userId: number,
	username: string,
	coins: number,
	petCount: number,
	rank: number,
}

export type LeaderboardData = {
	entries: { LeaderboardEntry },
	lastUpdated: number,
	playerRank: number?,
}

return {}
