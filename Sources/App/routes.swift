import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get { req -> Future<View> in
        struct PageData: Content {
            var juices: [Juice]
            var orders: [Order]
        }
        
        let cakes = Juice.query(on: req).all()
        let orders = Order.query(on: req).all()

        return flatMap(to: View.self, cakes, orders) { cakes, orders in
            let context = PageData(juices: cakes, orders: orders)
            return try req.view().render("home", context)
        }
        
//        return Juice.query(on: req).all().flatMap(to: View.self) {
//            juices in
//            return try req.view().render("home", ["juices": juices])
//        }
    }
    
    router.post(Juice.self, at: "add") { req, juice -> Future<Response> in
        return juice.save(on: req).map(to: Response.self) { juice in
            return req.redirect(to: "/")
        }
    }
    
    router.get("juices") { req -> Future<[Juice]> in
        return Juice.query(on: req).sort(\.name).all()
    }
    
//    router.post(Order.self, at: "order") { req, order -> Future<Order> in
//        var orderCopy = order
//        orderCopy.date = Date()
//        return orderCopy.save(on:req)
//    }
    
    router.get("orders") { req -> Future<[Order]> in
        return Order.query(on: req).sort(\.id).all()
    }

//   print(app.routes.all) // [Route]
}
