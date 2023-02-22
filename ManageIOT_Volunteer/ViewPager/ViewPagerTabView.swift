import UIKit

public final class ViewPagerTabView: UIView {

    internal var labelTitle: UILabel?
    internal var imageView : UIImageView?
    internal var viewAnchor: UIView?
    internal var width: CGFloat = 0
    internal var tab: ViewPagerTab?


    override init(frame: CGRect) {
        super.init(frame: frame)
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    internal func setup(tab: ViewPagerTab, options: ViewPagerOptions) {
        self.tab = tab
        switch options.tabType {
            case ViewPagerTabType.basic:
                setupBasicTab(options: options, tab: tab)
            case ViewPagerTabType.image:
                setupImageTab(options: options, tab: tab)
            case ViewPagerTabType.imageText:
                setupImageTextTab(options: options, tab: tab)
            case ViewPagerTabType.imageTextAnchor:
                setupImageTextAnchorTab(options: options, tab: tab)
        }
    }


    fileprivate func setupBasicTab(options: ViewPagerOptions, tab: ViewPagerTab) {
        buildLabelTitle(withOptions: options, text: tab.title)

        setupForAutolayout(view: labelTitle)
        labelTitle?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        labelTitle?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        labelTitle?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        labelTitle?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

        let distribution = options.distribution

        guard distribution == .equal || distribution == .normal else { return }

        let labelWidth = labelTitle!.intrinsicContentSize.width + options.tabViewPaddingLeft + options.tabViewPaddingRight
        width = labelWidth
    }


    fileprivate func setupImageTab(options: ViewPagerOptions, tab: ViewPagerTab) {
        let distribution = options.distribution
        let imageSize = options.tabViewImageSize

        buildImageView(withOptions: options, image: tab.imgOff)
        setupForAutolayout(view: imageView)

        imageView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView?.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        imageView?.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true

        switch distribution {
            case .segmented:
                break
            case .normal, .equal:
                // Determining the max width this tab should use
                let tabWidth = imageSize.width + options.tabViewPaddingRight + options.tabViewPaddingLeft
                self.width = tabWidth
        }
    }


    fileprivate func setupImageTextTab(options: ViewPagerOptions, tab: ViewPagerTab) {
        let distribution = options.distribution
        let imageSize = options.tabViewImageSize

        buildImageView(withOptions: options, image: tab.imgOff)
        buildLabelTitle(withOptions: options, text: tab.title)

        setupForAutolayout(view: imageView)
        setupForAutolayout(view: labelTitle)

        imageView?.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        imageView?.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        imageView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView?.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabViewImageMarginTop).isActive = true

        labelTitle?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        labelTitle?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        labelTitle?.topAnchor.constraint(equalTo: imageView!.bottomAnchor, constant: options.tabViewImageMarginBottom).isActive = true
        labelTitle?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        switch distribution {
            case .segmented:
                break
            case .normal, .equal:
                // Resetting tabview frame again with the new width
                let widthFromImage = imageSize.width + options.tabViewPaddingRight + options.tabViewPaddingLeft
                let widthFromText = labelTitle!.intrinsicContentSize.width + options.tabViewPaddingLeft + options.tabViewPaddingRight
                let tabWidth = max(widthFromImage, widthFromText)
                self.width = tabWidth
        }
    }


    fileprivate func setupImageTextAnchorTab(options: ViewPagerOptions, tab: ViewPagerTab) {
        let distribution = options.distribution
        let imageSize = options.tabViewImageSize

        buildImageView(withOptions: options, image: tab.imgOff)
        buildLabelTitle(withOptions: options, text: tab.title)
        buildViewAnchor(withOptions: options)

        setupForAutolayout(view: imageView)
        setupForAutolayout(view: labelTitle)
        setupForAutolayout(view: viewAnchor)

        imageView?.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        imageView?.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        imageView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView?.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabViewImageMarginTop).isActive = true

        labelTitle?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        labelTitle?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        labelTitle?.topAnchor.constraint(equalTo: imageView!.bottomAnchor, constant: options.tabViewImageMarginBottom).isActive = true
        labelTitle?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        viewAnchor?.leadingAnchor.constraint(equalTo: imageView!.trailingAnchor).isActive = true
        viewAnchor?.topAnchor.constraint(equalTo: imageView!.topAnchor).isActive = true
        viewAnchor?.widthAnchor.constraint(equalToConstant: 6).isActive = true
        viewAnchor?.heightAnchor.constraint(equalToConstant: 6).isActive = true

        switch distribution {
            case .segmented:
                break
            case .normal, .equal:
                // Resetting tabview frame again with the new width
                let widthFromImage = imageSize.width + options.tabViewPaddingRight + options.tabViewPaddingLeft
                let widthFromText = labelTitle!.intrinsicContentSize.width + options.tabViewPaddingLeft + options.tabViewPaddingRight
                let tabWidth = max(widthFromImage, widthFromText)
                self.width = tabWidth
        }
    }


    fileprivate func buildLabelTitle(withOptions options: ViewPagerOptions, text: String) {
        labelTitle = UILabel()
        labelTitle?.textAlignment = .center
        labelTitle?.textColor = options.tabViewTextDefaultColor
        labelTitle?.numberOfLines = 2
        labelTitle?.adjustsFontSizeToFitWidth = true
        labelTitle?.font = options.tabViewTextFont
        labelTitle?.text = text
    }


    fileprivate func buildImageView(withOptions options: ViewPagerOptions, image: UIImage?) {
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = image
    }


    fileprivate func buildViewAnchor(withOptions options: ViewPagerOptions) {
        viewAnchor = UIView()
        viewAnchor?.backgroundColor = UIColor.red
        viewAnchor?.frame.size.width  = 6
        viewAnchor?.frame.size.height = 6
        viewAnchor?.layer.masksToBounds = false
        viewAnchor?.layer.cornerRadius = (viewAnchor?.frame.height ?? 0) / 2
        viewAnchor?.clipsToBounds = true
        viewAnchor?.isHidden = true
    }


    internal func addHighlight(options: ViewPagerOptions) {
        backgroundColor = options.tabViewBackgroundHighlightColor
        labelTitle?.textColor = options.tabViewTextHighlightColor
        imageView?.image = tab?.imgSel
    }


    internal func removeHighlight(options: ViewPagerOptions) {
        backgroundColor = options.tabViewBackgroundDefaultColor
        labelTitle?.textColor = options.tabViewTextDefaultColor
        imageView?.image = tab?.imgOff
    }


    internal func setupForAutolayout(view: UIView?) {
        guard let v = view else { return }
        v.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(v)
    }


    func showAnchor() {
        DispatchQueue.main.async {
            self.viewAnchor?.isHidden = false
        }
    }


    func hideAnchor() {
        DispatchQueue.main.async {
            self.viewAnchor?.isHidden = true
        }
    }


}
