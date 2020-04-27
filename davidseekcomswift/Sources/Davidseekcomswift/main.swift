import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct Davidseekcomswift: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case blog
        case projects
        case cv
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://www.davidseek.com")!
    var name = "David Seek"
    var description = "Senior iOS Developer"
    var language: Language { .english }
    var imagePath: Path? { nil }
    
}

private extension Node where Context == HTML.BodyContext {
    
    static func wrapper(_ nodes: Node...) -> Node {
        .div(
            .class("wrapper"),
            .group(nodes)
        )
    }
    
    static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(
                    .article(
                        .h1(
                            .a(
                                .href(item.path),
                                .text(item.title)
                            )
                        ),
                        .p(
                            .text(item.description)
                        )
                    ))
            }
        )
    }
}

private extension Node where Context == HTML.BodyContext {
    
    static func myHeader<T: Website>(for context: PublishingContext<T>) -> Node {
        
        .header(
            .wrapper(
                .nav(
                    .class("site-name"),
                    .a(
                        .href("/blog/"),
                        .text(context.site.name)
                    )
                )
            )
        )
    }
    
    static func dsheader<T: Website>(for context: PublishingContext<T>, selectedSection: T.SectionID? = nil) -> Node {
        
        let sectionIDs = T.SectionID.allCases

        return .header(
                    .wrapper(
                        .a(
                            .class("site-name"),
                            .href("/blog/"),
                            .text(context.site.name)
                        ),
                        .wrapper(
                            .class("header__sub-title"),
                            .text(context.site.description)
                        ),
                        .if(sectionIDs.count > 1,
                            .nav(
                                .ul(
                                    .class("header__menu"),
                                    .forEach(sectionIDs) { section in
                                    .li(
                                        .a(
                                            .class(section == selectedSection ? "selected" : ""),
                                            .href(context.sections[section].path),
                                            .text(context.sections[section].title)
                                        ))
                                    })
                            )
                        )
                )
            )
    }
}


struct Factory<Site: Website>: HTMLFactory {
    
    func makeIndexHTML(for index: Index, context: PublishingContext<Site>) throws -> HTML {
        return HTML(
            .head(for: index, on: context.site),
            .body(
                
                .dsheader(for: context),
                
                .wrapper(
                    .ul(
                        .class("item-list"),
                        .forEach(context.allItems(sortedBy: \.date, order: .descending), { item in
                            .li(
                                .article(
                                    .h1(
                                        .a(
                                            .href(item.path),
                                            .text(item.title)
                                        )
                                    ),
                                    .p(.text(item.description))
                                )
                            )
                        })
                    )
                )
            )
        )
    }
    
    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        
        if let id = section.id as? Davidseekcomswift.SectionID, id == .cv {
            
            let item: Item<Site> = Item(
                path: "my-favorite-recipe",
                sectionID: id as! Site.SectionID,
                metadata: Davidseekcomswift.ItemMetadata() as! Site.ItemMetadata,
//                metadata: DeliciousRecipes.ItemMetadata(
//                    ingredients: ["Chocolate", "Coffee", "Flour"],
//                    preparationTime: 10 * 60
//                ),
                tags: ["favorite", "featured"],
                content: Content(
                    title: "Check out my favorite recipe!",
                    body: "Lorem ipsum"
                )
            )
            
            return HTML(
                    .head(for: item, on: context.site),
                    .body(
                        .myHeader(for: context),
                        .wrapper(
                            .article(
                                .contentBody(item.body)
                            )
                        )
                    )
                )
        }
        
        return HTML(
            .head(for: section, on: context.site),
            .body(
                .dsheader(for: context, selectedSection: section.id)
            )
        )
    }
    
    func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        return HTML(
            .head(for: item, on: context.site),
            .body(
                .myHeader(for: context),
                .wrapper(
                    .article(
                        .contentBody(item.body)
                    )
                )
            )
        )
    }
    
    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        return try makeIndexHTML(for: context.index, context: context)
    }
    
    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        return nil
    }
    
    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        return nil
    }
}

extension Theme {
    
    static var davidseek: Theme {
        Theme(
            htmlFactory: Factory(),
            resourcePaths: ["Resources/Theme/styles.css"]
        )
    }
}

// This will generate your website using the built-in Foundation theme:
try Davidseekcomswift()
    .publish(
        withTheme: .davidseek)
        //at: Path("/blog/"))
