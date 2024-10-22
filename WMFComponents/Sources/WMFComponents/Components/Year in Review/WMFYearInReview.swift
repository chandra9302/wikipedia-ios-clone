import SwiftUI

public struct WMFYearInReview: View {
    @ObservedObject var appEnvironment = WMFAppEnvironment.current
    @ObservedObject var viewModel: WMFYearInReviewViewModel

    var theme: WMFTheme {
        return appEnvironment.theme
    }
    
    public var donePressed: (() -> Void)?
    
    
    public init(viewModel: WMFYearInReviewViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().backgroundColor = theme.midBackground
    }
    
    let configuration = WMFSmallButton.Configuration(style: .quiet, trailingIcon: nil)

    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isFirstSlide {
                    WMFYearInReviewScrollView(scrollViewContents: scrollViewContent, contents: { AnyView(buttons) })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            viewModel.logYearInReviewSlideDidAppear()
                        }
                } else {
                    VStack {
                        TabView(selection: $viewModel.currentSlide) {
                            WMFSlideShow(currentSlide: $viewModel.currentSlide, slides: viewModel.slides)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 48)
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        viewModel.logYearInReviewSlideDidAppear()
                    }
                }
            }
            .background(Color(uiColor: theme.midBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.logYearInReviewDidTapDone()
                        donePressed?()
                    }) {
                        Text(viewModel.localizedStrings.doneButtonTitle)
                            .foregroundStyle(Color(uiColor: theme.link))
                            .font(Font(WMFFont.for(.semiboldHeadline)))
                    }
                }
                if !viewModel.isFirstSlide {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            // TODO: Implement Donation
                        }) {
                            HStack(alignment: .center, spacing: 6) {
                                if let uiImage = WMFSFSymbolIcon.for(symbol: .heartFilled, font: .semiboldHeadline) {
                                    Image(uiImage: uiImage)
                                        .foregroundStyle(Color(uiColor: theme.destructive))
                                }
                                Text(viewModel.localizedStrings.donateButtonTitle)
                                    .foregroundStyle(Color(uiColor: theme.destructive))
                            }
                            .font(Font(WMFFont.for(.semiboldHeadline)))
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack(alignment: .center) {
                            Button(action: {
                                // TODO: Implement share
                            }) {
                                HStack(alignment: .center, spacing: 6) {
                                    if let uiImage = WMFSFSymbolIcon.for(symbol: .share, font: .semiboldHeadline) {
                                        Image(uiImage: uiImage)
                                            .foregroundStyle(Color(uiColor: theme.link))
                                    }
                                    Text(viewModel.localizedStrings.shareButtonTitle)
                                        .foregroundStyle(Color(uiColor: theme.link))
                                }
                                .font(Font(WMFFont.for(.semiboldHeadline)))
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                            HStack(spacing: 9) {
                                ForEach(0..<viewModel.slides.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == viewModel.currentSlide ? Color(uiColor: theme.link) : Color(uiColor: theme.link.withAlphaComponent(0.3)))
                                        .frame(width: 7, height: 7)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    viewModel.nextSlide()
                                }
                            }) {
                                Text(viewModel.localizedStrings.nextButtonTitle)
                                    .foregroundStyle(Color(uiColor: theme.link))
                                    .font(Font(WMFFont.for(.semiboldHeadline)))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            Spacer()
        }
        .background(Color(uiColor: theme.midBackground))
        .navigationViewStyle(.stack)
        .environment(\.colorScheme, theme.preferredColorScheme)
        .frame(maxHeight: .infinity)
    }

    private var scrollViewContent: some View {
        VStack(spacing: 48) {
            VStack(alignment: .leading, spacing: 16) {
                Image("globe", bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 48)
                Text(viewModel.localizedStrings.firstSlideTitle)
                    .font(Font(WMFFont.for(.boldTitle1)))
                Text(viewModel.localizedStrings.firstSlideSubtitle)
                    .font(Font(WMFFont.for(.title3)))
            }
            .foregroundStyle(Color(uiColor: theme.text))
        }
    }
        
    private var buttons: some View {
        VStack {
            WMFLargeButton(configuration: .primary, title: viewModel.localizedStrings.firstSlideCTA) {
                withAnimation(.easeInOut(duration: 0.75)) {
                    viewModel.loggingDelegate?.logYearInReviewIntroDidTapContinue()
                    viewModel.getStarted()
                }
            }
            WMFSmallButton(configuration: configuration, title: viewModel.localizedStrings.firstSlideHide) {
                viewModel.loggingDelegate?.logYearInReviewIntroDidTapDisable()
                // TODO: Implement hide this feature
            }
        }
    }
}
