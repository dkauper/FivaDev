//
//  GameState.swift
//  FivaDev
//
//  Created: October 12, 2025, 6:10 PM Pacific
//  Game state model with support for pre-game configuration dialog
//  MAX 3 TEAMS: Red, Blue, Green only (Yellow will not be implemented)
//  MAX 12 PLAYERS: Can be distributed across the 3 teams
//

import Foundation

/// Represents the current state of a Fiva game
struct GameState: Codable {
    // MARK: - Game Configuration (Set via Pre-Game Dialog)
    
    /// Number of players in the game (2-12)
    var numPlayers: Int {
        didSet {
            // Enforce 2-12 player limit
            numPlayers = max(2, min(12, numPlayers))
        }
    }
    
    /// Number of teams (2-3, limited by available chip colors: Red, Blue, Green)
    var numTeams: Int {
        didSet {
            // Enforce 2-3 team limit (chip color constraint)
            numTeams = max(2, min(3, numTeams))
        }
    }
    
    /// Index of current player (0-based)
    var currentPlayer: Int
    
    /// Player names (set by pre-game dialog, defaults provided)
    var playerNames: [String]
    
    /// Team assignments: maps player index to team index (0-2)
    /// Example: [0,0,1,1] = Players 1&2 on Team 1, Players 3&4 on Team 2
    var playerTeams: [Int]
    
    // MARK: - Computed Properties
    
    /// Cards dealt per player based on player count
    var cardsPerPlayer: Int {
        switch numPlayers {
        case 2: return 7
        case 3, 4: return 6
        case 5, 6: return 5
        case 7, 8, 9: return 4
        case 10, 11, 12: return 3
        default: return 6  // Fallback
        }
    }
    
    /// FIVAs needed to win based on player/team count
    var fivasToWin: Int {
        switch numTeams {
        case 2: return 2  // 2 teams need TWO 5-in-a-rows
        case 3: return 1  // 3 teams need ONE 5-in-a-row
        default: return 1
        }
    }
    
    /// Gets the team index for a given player
    func teamFor(player: Int) -> Int {
        guard player >= 0 && player < playerTeams.count else {
            return 0  // Default to team 0
        }
        return playerTeams[player]
    }
    
    /// Gets the chip color for a given player based on their team
    func colorFor(player: Int) -> PlayerColor {
        let team = teamFor(player: player)
        return PlayerColor.forTeam(team)
    }
    
    // MARK: - Initialization
    
    /// Creates a new game state with specified configuration
    /// - Parameters:
    ///   - numPlayers: Number of players (2-12, will be clamped)
    ///   - numTeams: Number of teams (2-3, will be clamped)
    ///   - playerNames: Custom player names (optional)
    ///   - playerTeams: Team assignments (optional, will auto-distribute if nil)
    ///   - currentPlayer: Starting player index
    init(
        numPlayers: Int = 2,
        numTeams: Int = 2,
        playerNames: [String]? = nil,
        playerTeams: [Int]? = nil,
        currentPlayer: Int = 0
    ) {
        self.numPlayers = max(2, min(12, numPlayers))  // Enforce 2-12 limit
        self.numTeams = max(2, min(3, numTeams))       // Enforce 2-3 limit
        self.currentPlayer = currentPlayer
        
        // Use provided names or generate defaults
        if let names = playerNames {
            self.playerNames = names
        } else {
            self.playerNames = Self.defaultPlayerNames(for: self.numPlayers)
        }
        
        // Use provided team assignments or auto-distribute
        if let teams = playerTeams {
            self.playerTeams = teams
        } else {
            self.playerTeams = Self.distributePlayersToTeams(
                players: self.numPlayers,
                teams: self.numTeams
            )
        }
    }
    
    /// Generates default player names
    private static func defaultPlayerNames(for count: Int) -> [String] {
        return (1...count).map { "Player \($0)" }
    }
    
    /// Distributes players evenly across teams
    /// Example: 6 players, 3 teams → [0,1,2,0,1,2]
    private static func distributePlayersToTeams(players: Int, teams: Int) -> [Int] {
        return (0..<players).map { $0 % teams }
    }
    
    // MARK: - Player Management
    
    /// Advances to the next player
    mutating func advanceToNextPlayer() {
        currentPlayer = (currentPlayer + 1) % numPlayers
    }
    
    /// Resets to first player
    mutating func resetToFirstPlayer() {
        currentPlayer = 0
    }
    
    /// Validates player index
    func isValidPlayerIndex(_ index: Int) -> Bool {
        return index >= 0 && index < numPlayers
    }
    
    /// Gets the name of the current player
    var currentPlayerName: String {
        guard currentPlayer >= 0 && currentPlayer < playerNames.count else {
            return "Player \(currentPlayer + 1)"
        }
        return playerNames[currentPlayer]
    }
    
    /// Gets the team name for current player
    var currentTeamName: String {
        return colorFor(player: currentPlayer).displayName
    }
    
    // MARK: - Game Setup
    
    /// Configures game for new match (called after pre-game dialog)
    /// - Parameters:
    ///   - players: Number of players (2-12)
    ///   - teams: Number of teams (2-3)
    ///   - names: Player names from dialog
    ///   - teamAssignments: Team assignments from dialog
    mutating func configure(
        players: Int,
        teams: Int,
        names: [String],
        teamAssignments: [Int]? = nil
    ) {
        self.numPlayers = max(2, min(12, players))
        self.numTeams = max(2, min(3, teams))
        self.playerNames = names
        
        if let assignments = teamAssignments {
            self.playerTeams = assignments
        } else {
            self.playerTeams = Self.distributePlayersToTeams(
                players: self.numPlayers,
                teams: self.numTeams
            )
        }
        
        self.currentPlayer = 0
    }
    
    /// Resets state for new game with same configuration
    mutating func resetForNewGame() {
        currentPlayer = 0
    }
}

// MARK: - Default Configurations (For Testing)

extension GameState {
    // MARK: - Individual Player Presets (1 player per team)
    
    /// 2 players, 2 teams (1v1)
    static let twoPlayer = GameState(
        numPlayers: 2,
        numTeams: 2,
        playerNames: ["Player 1", "Player 2"],
        playerTeams: [0, 1],
        currentPlayer: 0
    )
    
    /// 3 players, 3 teams (1v1v1)
    static let threePlayer = GameState(
        numPlayers: 3,
        numTeams: 3,
        playerNames: ["Player 1", "Player 2", "Player 3"],
        playerTeams: [0, 1, 2],
        currentPlayer: 0
    )
    
    // MARK: - 4 Player Presets
    
    /// 4 players, 2 teams (2v2)
    static let fourPlayer2v2 = GameState(
        numPlayers: 4,
        numTeams: 2,
        playerNames: ["P1", "P2", "P3", "P4"],
        playerTeams: [0, 1, 0, 1],  // Alternating teams
        currentPlayer: 0
    )
    
    // MARK: - 6 Player Presets
    
    /// 6 players, 2 teams (3v3)
    static let sixPlayer3v3 = GameState(
        numPlayers: 6,
        numTeams: 2,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6"],
        playerTeams: [0, 1, 0, 1, 0, 1],  // Alternating teams
        currentPlayer: 0
    )
    
    /// 6 players, 3 teams (2v2v2)
    static let sixPlayer2v2v2 = GameState(
        numPlayers: 6,
        numTeams: 3,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6"],
        playerTeams: [0, 1, 2, 0, 1, 2],  // Round-robin teams
        currentPlayer: 0
    )
    
    // MARK: - 8 Player Presets
    
    /// 8 players, 2 teams (4v4)
    static let eightPlayer4v4 = GameState(
        numPlayers: 8,
        numTeams: 2,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8"],
        playerTeams: [0, 1, 0, 1, 0, 1, 0, 1],  // Alternating teams
        currentPlayer: 0
    )
    
    // MARK: - 9 Player Presets
    
    /// 9 players, 3 teams (3v3v3)
    static let ninePlayer3v3v3 = GameState(
        numPlayers: 9,
        numTeams: 3,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9"],
        playerTeams: [0, 1, 2, 0, 1, 2, 0, 1, 2],  // Round-robin teams
        currentPlayer: 0
    )
    
    // MARK: - 10 Player Presets
    
    /// 10 players, 2 teams (5v5)
    static let tenPlayer5v5 = GameState(
        numPlayers: 10,
        numTeams: 2,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10"],
        playerTeams: [0, 1, 0, 1, 0, 1, 0, 1, 0, 1],  // Alternating teams
        currentPlayer: 0
    )
    
    // MARK: - 12 Player Presets
    
    /// 12 players, 2 teams (6v6)
    static let twelvePlayer6v6 = GameState(
        numPlayers: 12,
        numTeams: 2,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10", "P11", "P12"],
        playerTeams: [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],  // Alternating teams
        currentPlayer: 0
    )
    
    /// 12 players, 3 teams (4v4v4)
    static let twelvePlayer4v4v4 = GameState(
        numPlayers: 12,
        numTeams: 3,
        playerNames: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10", "P11", "P12"],
        playerTeams: [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2],  // Round-robin teams
        currentPlayer: 0
    )
    
    // MARK: - Factory Methods
    
    /// Creates a game configuration with balanced teams
    /// - Parameters:
    ///   - players: Number of players (2-12)
    ///   - teams: Number of teams (2-3)
    /// - Returns: GameState with players evenly distributed across teams
    static func balanced(players: Int, teams: Int) -> GameState {
        let clampedPlayers = max(2, min(12, players))
        let clampedTeams = max(2, min(3, teams))
        
        let names = (1...clampedPlayers).map { "Player \($0)" }
        let assignments = (0..<clampedPlayers).map { $0 % clampedTeams }
        
        return GameState(
            numPlayers: clampedPlayers,
            numTeams: clampedTeams,
            playerNames: names,
            playerTeams: assignments,
            currentPlayer: 0
        )
    }
    
    /// Creates a game configuration with custom team assignments
    /// - Parameters:
    ///   - players: Number of players (2-12)
    ///   - teams: Number of teams (2-3)
    ///   - teamAssignments: Custom team assignment array
    ///   - names: Optional custom player names
    /// - Returns: GameState with specified configuration
    static func custom(
        players: Int,
        teams: Int,
        teamAssignments: [Int],
        names: [String]? = nil
    ) -> GameState {
        let clampedPlayers = max(2, min(12, players))
        let clampedTeams = max(2, min(3, teams))
        
        let playerNames = names ?? (1...clampedPlayers).map { "Player \($0)" }
        
        // Validate team assignments
        let validatedAssignments = teamAssignments.prefix(clampedPlayers).map {
            max(0, min(clampedTeams - 1, $0))
        }
        
        return GameState(
            numPlayers: clampedPlayers,
            numTeams: clampedTeams,
            playerNames: playerNames,
            playerTeams: Array(validatedAssignments),
            currentPlayer: 0
        )
    }
    
    /// Quick test configuration with auto-balancing
    static func test(players: Int = 3, teams: Int = 3) -> GameState {
        return balanced(players: players, teams: teams)
    }
}

// MARK: - Valid Configuration Helper

extension GameState {
    /// Returns all valid even-team configurations for a given player count
    static func validConfigurations(for players: Int) -> [(teams: Int, playersPerTeam: String)] {
        var configs: [(Int, String)] = []
        
        // Check if divisible by 2
        if players % 2 == 0 {
            configs.append((2, "\(players/2)v\(players/2)"))
        }
        
        // Check if divisible by 3
        if players % 3 == 0 {
            let perTeam = players / 3
            configs.append((3, "\(perTeam)v\(perTeam)v\(perTeam)"))
        }
        
        return configs
    }
    
    /// Checks if current configuration has balanced teams
    var isBalanced: Bool {
        var teamCounts = [Int: Int]()
        for team in playerTeams {
            teamCounts[team, default: 0] += 1
        }
        
        let counts = Array(teamCounts.values)
        guard let first = counts.first else { return false }
        return counts.allSatisfy { $0 == first }
    }
    
    /// Returns team size distribution (e.g., [3, 3] for 3v3)
    var teamSizes: [Int] {
        var teamCounts = [Int: Int]()
        for team in playerTeams {
            teamCounts[team, default: 0] += 1
        }
        return (0..<numTeams).map { teamCounts[$0] ?? 0 }
    }
    
    /// Human-readable team configuration (e.g., "3v3", "2v2v2")
    var teamConfigurationDescription: String {
        let sizes = teamSizes
        return sizes.map { "\($0)" }.joined(separator: "v")
    }
}
