import UIKit
import WMF
import WMFComponents
import WMFData
import CocoaLumberjackSwift

@objc(WMFHistoryViewController)
class HistoryViewController: ArticleFetchedResultsViewController, WMFNavigationBarConfiguring {

    override func setupFetchedResultsController(with dataStore: MWKDataStore) {
        let articleRequest = WMFArticle.fetchRequest()
        articleRequest.predicate = NSPredicate(format: "viewedDate != NULL")
        articleRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WMFArticle.viewedDateWithoutTime, ascending: false), NSSortDescriptor(keyPath: \WMFArticle.viewedDate, ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: articleRequest, managedObjectContext: dataStore.viewContext, sectionNameKeyPath: "viewedDateWithoutTime", cacheName: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBar.isBarHidingEnabled = false
//        navigationBar.isShadowHidingEnabled = true
//        navigationBar.displayType = .largeTitle

        emptyViewType = .noHistory
        
        title = CommonStrings.historyTabTitle
        
        deleteAllButtonText = WMFLocalizedString("history-clear-all", value: "Clear", comment: "Text of the button shown at the top of history which deletes all history {{Identical|Clear}}")
        deleteAllConfirmationText =  WMFLocalizedString("history-clear-confirmation-heading", value: "Are you sure you want to delete all your recent items?", comment: "Heading text of delete all confirmation dialog")
        deleteAllCancelText = WMFLocalizedString("history-clear-cancel", value: "Cancel", comment: "Button text for cancelling delete all action {{Identical|Cancel}}")
        deleteAllText = WMFLocalizedString("history-clear-delete-all", value: "Yes, delete all", comment: "Button text for confirming delete all action")
        isDeleteAllVisible = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionViewUpdater.isGranularUpdatingEnabled = true
        
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSUserActivity.wmf_makeActive(NSUserActivity.wmf_recentView())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionViewUpdater.isGranularUpdatingEnabled = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 18, *) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
                    configureNavigationBar()
                }
            }
        }
    }
    
    override func deleteAll() {
        do {
            try dataStore.viewContext.clearReadHistory()
        } catch let error {
            showError(error)
        }
        
        Task {
            do {
                let dataController = try WMFPageViewsDataController()
                try await dataController.deleteAllPageViews()
            } catch {
                DDLogError("Failure deleting WMFData WMFPageViews: \(error)")
            }
            
        }
    }
    
    override func delete(at indexPath: IndexPath) {
        
        guard let article = article(at: indexPath) else {
            return
        }
        
        super.delete(at: indexPath)

        // Also delete from WMFData WMFPageViews
        guard let title = article.url?.wmf_title,
              let languageCode = article.url?.wmf_languageCode else {
            return
        }
        
        let variant = article.variant
        
        let project = WMFProject.wikipedia(WMFLanguage(languageCode: languageCode, languageVariantCode: variant))
        
        Task {
            do {
                let dataController = try WMFPageViewsDataController()
                try await dataController.deletePageView(title: title, namespaceID: 0, project: project)
            } catch {
                DDLogError("Failure deleting WMFData WMFPageViews: \(error)")
            }
            
        }
    }
    
    private func configureNavigationBar() {
        
        var titleConfig: WMFNavigationBarTitleConfig = WMFNavigationBarTitleConfig(title: CommonStrings.historyTabTitle, customView: nil, alignment: .leadingCompact)
        if #available(iOS 18, *) {
            if UIDevice.current.userInterfaceIdiom == .pad && traitCollection.horizontalSizeClass == .regular {
                titleConfig = WMFNavigationBarTitleConfig(title: CommonStrings.historyTabTitle, customView: nil, alignment: .leadingLarge)
            }
        }

        configureNavigationBar(titleConfig: titleConfig, closeButtonConfig: nil, profileButtonConfig: nil, searchBarConfig: nil, hideNavigationBarOnScroll: false)
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        guard let sections = fetchedResultsController.sections, sections.count > section else {
            return nil
        }
        let sectionInfo = sections[section]
        guard let article = sectionInfo.objects?.first as? WMFArticle, let date = article.viewedDateWithoutTime else {
            return nil
        }
        
        return ((date as NSDate).wmf_midnightUTCDateFromLocal as NSDate).wmf_localizedRelativeDateFromMidnightUTCDate()
    }
    
    override func configure(header: CollectionViewHeader, forSectionAt sectionIndex: Int, layoutOnly: Bool) {
        header.style = .history
        header.title = titleForHeaderInSection(sectionIndex)
        header.apply(theme: theme)
        header.layoutMargins = layout.itemLayoutMargins
    }
    
    override func collectionViewUpdater<T>(_ updater: CollectionViewUpdater<T>, didUpdate collectionView: UICollectionView) {
        super.collectionViewUpdater(updater, didUpdate: collectionView)
        updateVisibleHeaders()
    }

    func updateVisibleHeaders() {
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader) {
            guard let headerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? CollectionViewHeader else {
                continue
            }
            headerView.title = titleForHeaderInSection(indexPath.section)
        }
    }
    
    override var eventLoggingCategory: EventCategoryMEP {
        return .history
    }
}
