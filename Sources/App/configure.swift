import Fluent
import FluentPostgreSQL
import Leaf
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
     
    // Configure Directory Path
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)

    // Register providers first
    try services.register(FluentPostgreSQLProvider()) // Configure to Real PSQL
    // try services.register(FluentProvider()) // Configure to Dummy PSQL

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,    // Wildcard All Origin (Domain)
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    ) // CORS Allow Control Acces Cross Origin Policy
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)

    middlewares.use(corsMiddleware) // Allow Control Access Cross Origin
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)   

    
    // Configure With a PostgreSQL database local
    let config = PostgreSQLDatabaseConfig(
        hostname: "localhost",
        port: 5432,
        username: "metalbee",
        database: "JuicesCorner",
        password: nil,
        transport: .cleartext)
    
    // Configure a PostgreSQL database cloud
    // let config = PostgreSQLDatabaseConfig(
    //     hostname: "",
    //     port: 5432,
    //     username: "",
    //     database: "",
    //     password: "",
    //     transport: .cleartext)

    let postgres = PostgreSQLDatabase(config: config)

    // Register the configured PostgreSQL database to the database config.
    var databasesConfig = DatabasesConfig()
    databasesConfig.add(database: postgres, as: .psql) // Configure for real PSQL
    services.register(databasesConfig)

    // let db = try PostgreSQLDatabase(storage: .file(path: "\(directoryConfig.workDir)juices.db"))   
    // databaseConfig.add(database: db, as: .psql)  // Configure for dummy PSQL
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Juice.self, database: .psql)
    migrations.add(model: Order.self, database: .psql)
    services.register(migrations)
    
}
