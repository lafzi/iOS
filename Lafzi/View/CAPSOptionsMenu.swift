//
//  OptionsMenu.swift
//  VeriForm
//
//  Created by Niklas Fahl on 8/31/15.
//  Copyright © 2015 CAPS. All rights reserved.
//
//  DISCLAIMER: Works on iPhone 5 or newer as well as all iPads on iOS 7 or newer

import UIKit

public enum AnimationOption:Int {
    case fade
    case expand
    case none
}

public class CAPSOptionsMenu: UIView, UIGestureRecognizerDelegate {
    
    private var parentViewController: UIViewController?
    private var targetNavigationController: UINavigationController?
    
    private var barItem: UIBarButtonItem?
    private var menuScrollView: UIScrollView?
    
    var isShown: Bool = false
    private var didTapActionButton: Bool = false
    
    private var actions: [CAPSOptionsMenuAction] = []
    private var actionButtons: [CAPSOptionsMenuButton] = []
    
    private var barButtonX: CGFloat = 0.0
    private var barButtonXOrientation: UIInterfaceOrientation = UIInterfaceOrientation.unknown
    private var barButtonView: UIView = UIView()
    
    private var closedFrame: CGRect = CGRect.zero
    private var openedFrame: CGRect = CGRect.zero
    
    // Customization options defaults
    var menuKeepBarButtonAtEdge: Bool = true
    var maxMenuWidth: CGFloat = 200.0
    var hasShadow: Bool = true
    var menuShadowColor: UIColor = UIColor.gray
    var menuBackgroundColor: UIColor = UIColor.white
    var menuBorderWidth: CGFloat = 0.0
    var menuBorderColor: UIColor = UIColor.black
    var menuActionButtonsTitleColor: UIColor = UIColor.black
    var menuActionButtonsHiglightedColor: UIColor = UIColor.lightGray
    var menuCornerRadius: CGFloat = 0.0
    var menuAnimationOption: AnimationOption = AnimationOption.expand
    var menuAnimationDuration = 0.2
    
    /// Initialize with parent view controller and bar button image name
    ///
    /// -parameters:
    ///   - viewController: View controller holding the navigation controller with the navigation bar the menu is to be put on
    ///   - imageName: Name for menu bar button image
    ///   - keepBarButtonOnRightEdge: If `true`, menu bar button will always stay on the rightmost position
    public init(viewController: UIViewController, imageName: String, keepBarButtonAtEdge: Bool) {
        parentViewController = viewController
        targetNavigationController = viewController.navigationController
        super.init(frame: targetNavigationController!.view.frame)
        
        addBarButtonWithImageName(name: imageName)
        
        menuKeepBarButtonAtEdge = keepBarButtonAtEdge
        setUpOptionsMenu()
    }
    
    /// Initialize with parent view controller and bar button image
    ///
    /// -parameters:
    ///   - viewController: View controller holding the navigation controller with the navigation bar the menu is to be put on
    ///   - image: Image for menu bar button
    ///   - keepBarButtonOnRightEdge: If `true`, menu bar button will always stay on the rightmost position
    public init(viewController: UIViewController, image: UIImage, keepBarButtonAtEdge: Bool) {
        parentViewController = viewController
        targetNavigationController = viewController.navigationController
        super.init(frame: targetNavigationController!.view.frame)
        
        addBarButtonWithImage(image: image)
        
        menuKeepBarButtonAtEdge = keepBarButtonAtEdge
        setUpOptionsMenu()
    }
    
    /// Initialize with parent view controller and bar button system item
    ///
    /// -parameters:
    ///   - viewController: View controller holding the navigation controller with the navigation bar the menu is to be put on
    ///   - barButtonSystemItem: Bar button system item for menu bar button
    ///   - keepBarButtonOnRightEdge: If `true`, menu bar button will always stay on the rightmost position
    public init(viewController: UIViewController, barButtonSystemItem: UIBarButtonItem.SystemItem, keepBarButtonAtEdge: Bool) {
        parentViewController = viewController
        targetNavigationController = viewController.navigationController
        super.init(frame: targetNavigationController!.view.frame)
        
        addBarButtonWithSystemItem(systemItem: barButtonSystemItem)
        
        menuKeepBarButtonAtEdge = keepBarButtonAtEdge
        setUpOptionsMenu()
    }
    
    
    public init(viewController: UIViewController, barButtonItem: UIBarButtonItem, keepBarButtonAtEdge: Bool) {
        parentViewController = viewController
        targetNavigationController = viewController.navigationController
        super.init(frame: targetNavigationController!.view.frame)
        
        barItem = barButtonItem
        barItem?.target = self
        barItem?.action = #selector(barButtonAction(sender:event:))
        // addItemToNavigationBar()
        
        menuKeepBarButtonAtEdge = keepBarButtonAtEdge
        setUpOptionsMenu()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Set up
    private func setUpOptionsMenu() {
        self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        targetNavigationController?.view.insertSubview(self, aboveSubview: targetNavigationController!.navigationBar)
        
        self.isHidden = true
        self.backgroundColor = UIColor.clear
        
        setUpMenuView()
    }
    
    private func setUpMenuView() {
        menuScrollView = UIScrollView(frame: closedFrame)
        menuScrollView?.backgroundColor = menuBackgroundColor
        menuScrollView?.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        self.addSubview(menuScrollView!)
        
        let backgroundTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CAPSOptionsMenu.toggleMenu))
        backgroundTapGesture.delegate = self
        self.addGestureRecognizer(backgroundTapGesture)
        
        if menuCornerRadius > 0.0 {
            menuScrollView!.layer.cornerRadius = menuCornerRadius
            menuScrollView!.clipsToBounds = true
        }
        
        if hasShadow { addShadowAndCornerRadiusToMenuView() }
        if menuBorderWidth > 0.0 { addBorderToMenuView() }
    }
    
    private func addShadowAndCornerRadiusToMenuView() {
        self.layer.shadowColor = menuShadowColor.cgColor
        self.layer.shadowOffset = CGSize(width:0, height:0)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = true
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func addBorderToMenuView() {
        menuScrollView?.layer.borderWidth = menuBorderWidth
        menuScrollView?.layer.borderColor = menuBorderColor.cgColor
    }
    
    // MARK: - Customization
    
    /// Menu Customization
    ///
    /// This methods lets you customize every customization option in one method call
    ///
    /// - parameters:
    ///   - width: Maximum width of the menu
    ///   - shadow: If `true`, shadow is added to the menu
    ///   - shadowColor: Shadow color for the menu
    ///   - backgroundColor: Background color for the menu
    ///   - borderWidth: Border width for the menu
    ///   - borderColor: Border color for the menu
    ///   - actionButtonsTitleColor: Title color for the menu action buttons
    ///   - actionButtonsHighlightedColor: Background color for the menu action buttons when tapped
    ///   - cornerRadius: Corner radius for the menu
    ///   - animationOption: Animation option for the menu open/close animation style
    ///   - animationDuration: Animation duration for the menu open/close animation
    public func customizeWith(maxMenuWidth: CGFloat?, shadow: Bool?, shadowColor: UIColor?, backgroundColor: UIColor?, borderWidth: CGFloat?, borderColor: UIColor?, actionButtonsTitleColor: UIColor?, actionButtonsHighlightedColor: UIColor?, cornerRadius: CGFloat?, animationOption: AnimationOption?, animationDuration: TimeInterval?) {
        if let mMenuWidth = maxMenuWidth { self.maxMenuWidth = mMenuWidth }
        if let sh = shadow { hasShadow = sh }
        if let shColor = shadowColor { menuShadowColor = shColor }
        if let bgColor = backgroundColor { menuBackgroundColor = bgColor }
        if let bWidth = borderWidth { menuBorderWidth = bWidth }
        if let bColor = borderColor { menuBorderColor = bColor }
        if let aBTColor = actionButtonsTitleColor { menuActionButtonsTitleColor = aBTColor }
        if let aBHColor = actionButtonsHighlightedColor { menuActionButtonsHiglightedColor = aBHColor }
        if let cRadius = cornerRadius { menuCornerRadius = cRadius }
        if let aOption = animationOption { menuAnimationOption = aOption }
        if let aDuration = animationDuration { menuAnimationDuration = aDuration }
        
        updateForCustomizationOptions()
    }
    
    private func updateForCustomizationOptions() {
        menuScrollView?.backgroundColor = menuBackgroundColor
        
        if menuCornerRadius > 0.0 {
            menuScrollView!.layer.cornerRadius = menuCornerRadius
            menuScrollView!.clipsToBounds = true
        }
        
        if hasShadow {
            addShadowAndCornerRadiusToMenuView()
        } else {
            // Remove shadow
            self.layer.shadowRadius = 0.0
            self.layer.shadowOpacity = 0.0
        }
        
        if menuBorderWidth > 0.0 { addBorderToMenuView() }
    }
    
    // MARK: - Customization Setters
    
    /// Menu Max Width
    /// - parameters:
    ///   - width: Maximum width of the menu
    public func menuMaxWidth(width: CGFloat) {
        maxMenuWidth = width
    }
    
    /// Menu Has Shadow
    /// - parameters:
    ///   - shadow: If `true`, shadow is added to the menu
    public func menuHasShadow(shadow: Bool) {
        hasShadow = shadow
        
        if hasShadow {
            addShadowAndCornerRadiusToMenuView()
        } else {
            // Remove shadow
            self.layer.shadowRadius = 0.0
            self.layer.shadowOpacity = 0.0
        }
    }
    
    /// Menu Shadow Color
    /// - parameters:
    ///   - color: Shadow color for the menu
    public func menuShadowColor(color: UIColor) {
        menuShadowColor = color
        self.layer.shadowColor = menuShadowColor.cgColor
    }
    
    /// Menu Background Color
    /// - parameters:
    ///   - color: Background color for the menu
    public func menuBackgroundColor(color: UIColor) {
        menuBackgroundColor = color
        menuScrollView?.backgroundColor = menuBackgroundColor
    }
    
    /// Menu Border Width
    /// - parameters:
    ///   - width: Border width for the menu
    public func menuBorderWidth(width: CGFloat) {
        menuBorderWidth = width
        if menuBorderWidth > 0.0 { addBorderToMenuView() }
    }
    
    /// Menu Border Color
    /// - parameters:
    ///   - color: Border color for the menu
    public func menuBorderColor(color: UIColor) {
        menuBorderColor = color
        if menuBorderWidth > 0.0 { addBorderToMenuView() }
    }
    
    /// Menu Action Buttons Title Color
    /// - parameters:
    ///   - color: Title color for the menu action buttons
    public func menuActionButtonsTitleColor(color: UIColor) {
        menuActionButtonsTitleColor = color
    }
    
    /// Menu Action Buttons Highlighted Color
    /// - parameters:
    ///   - color: Background color for the menu action buttons when tapped
    public func menuActionButtonsHighlightedColor(color: UIColor) {
        menuActionButtonsHiglightedColor = color
    }
    
    /// Menu Corner Radius
    /// - parameters:
    ///   - radius: Corner radius for the menu
    public func menuCornerRadius(radius: CGFloat) {
        menuCornerRadius = radius
        if menuCornerRadius > 0.0 {
            menuScrollView!.layer.cornerRadius = menuCornerRadius
            menuScrollView!.clipsToBounds = true
        }
    }
    
    /// Menu Animation Option
    /// - parameters:
    ///   - option: Animation option for the menu open/close animation style
    public func menuAnimationOption(option: AnimationOption) {
        menuAnimationOption = option
    }
    public func menuAnimationOption(option: Int) {
        switch(option){
        case 0:
            menuAnimationOption = AnimationOption.expand
        case 1:
            menuAnimationOption = AnimationOption.fade
        case 2:
            menuAnimationOption = AnimationOption.none
        default:break
        }
        
    }
    
    /// Menu Animation Duration
    /// - parameters:
    ///   - duration: Animation duration for the menu open/close animation
    public func menuAnimationDuration(duration: TimeInterval) {
        menuAnimationDuration = duration
    }
    
    // MARK: - Bar Button Item
    private func addBarButtonWithImageName(name: String) {
        barItem = UIBarButtonItem(image: UIImage(named: name), style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonAction(sender:event:)))
        addItemToNavigationBar()
    }
    
    private func addBarButtonWithImage(image: UIImage) {
        barItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonAction(sender:event:)))
        addItemToNavigationBar()
    }
    
    private func addBarButtonWithSystemItem(systemItem: UIBarButtonItem.SystemItem) {
        barItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(barButtonAction(sender:event:)))
        addItemToNavigationBar()
    }
    
    
    
    
    private func addItemToNavigationBar() {
        if barItem != nil {
            if let navigationItem = parentViewController?.navigationItem {
                if (navigationItem.rightBarButtonItems?.count)! > 1
                {
                    let tempBarButtons = navigationItem.rightBarButtonItems
                    if menuKeepBarButtonAtEdge {
                        navigationItem.rightBarButtonItems? = [barItem!] + tempBarButtons!
                    } else {
                        navigationItem.rightBarButtonItems? = tempBarButtons! + [barItem!]
                    }
                }
                else if navigationItem.rightBarButtonItem != nil
                {
                    let tempBarButton : UIBarButtonItem = navigationItem.rightBarButtonItem!
                    if menuKeepBarButtonAtEdge {
                        navigationItem.rightBarButtonItems = [barItem!, tempBarButton]
                    } else {
                        navigationItem.rightBarButtonItems = [tempBarButton, barItem!]
                    }
                }
                else
                {
                    navigationItem.rightBarButtonItem = barItem!
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func getNavigationBarHeight() -> CGFloat {
        return targetNavigationController!.navigationBar.frame.origin.y + targetNavigationController!.navigationBar.frame.height
    }
    
    private func getScreenBoundsForInterfaceOrientation(orientation: UIInterfaceOrientation) -> CGRect {
        var deviceWidth: CGFloat = 0.0
        var deviceHeight: CGFloat = 0.0
        
        if (orientation == UIInterfaceOrientation.landscapeLeft || orientation == UIInterfaceOrientation.landscapeRight)
        { // Landscape
            deviceWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            deviceHeight = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
        else
        { // Portrait
            deviceWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            deviceHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
        
        return CGRect(x:0.0, y:0.0, width:deviceWidth,height: deviceHeight)
    }
    
    private func setOpenClosedFrameForBarButtonFrame(statusBarOrientation: UIInterfaceOrientation) {
        // Get appropriate screen bounds for actual interface orientation
        let screenBounds = getScreenBoundsForInterfaceOrientation(orientation: statusBarOrientation)
        
        // calculate y offset for bar button and make appropriate rect for bar button frame
        let navigationBarFrame = targetNavigationController!.navigationBar.frame
        let barButtonY = navigationBarFrame.origin.y + barButtonView.frame.origin.y
        let frame = CGRect(x:barButtonX, y:barButtonY,width: barButtonView.frame.width,height: barButtonView.frame.height)
        
        // Calculate opened frames for menu
        let barButtonRightOffset = screenBounds.width - frame.maxX
        let menuWidth = min(maxMenuWidth, screenBounds.width - barButtonRightOffset - barButtonY)
        let barMenuY = (navigationBarFrame.origin.y == 0 ? barButtonY : barButtonY - navigationBarFrame.origin.y)
        let menuHeight = min(CGFloat(44 * actions.count), parentViewController!.view.frame.height + navigationBarFrame.height - barMenuY - barButtonY)
        let barMenuX = barButtonX + barButtonView.frame.width - menuWidth
        openedFrame = CGRect(x:barMenuX,y: barButtonY,width: menuWidth, height:menuHeight)
        
        // Calculate opened frames for menu
        let barButtonCenterX = frame.midX
        let barButtonCenterY = frame.midY
        closedFrame = CGRect(x:barButtonCenterX, y:barButtonCenterY - 5.0, width:0.0, height:0.0)
        
        // Update frames
        menuScrollView?.frame = isShown ? openedFrame : closedFrame
        let actionsHeight: CGFloat = CGFloat(44 * actions.count)
        menuScrollView!.contentSize = CGSize(width:menuScrollView!.frame.width, height:actionsHeight)
        
        // Update button width
        for button in actionButtons {
            button.frame = CGRect(x:button.frame.origin.x,y: button.frame.origin.y, width:menuWidth, height: button.frame.height)
        }
    }
    
    // MARK: - Menu Functions
    @objc public func barButtonAction(sender:UIBarButtonItem, event: UIEvent) {
        if let touches = event.allTouches {
            if let touch = touches.first {
                if let view = touch.view {
                    // Save info about bar button
                    barButtonView = view
                    barButtonX = view.frame.origin.x
                    barButtonXOrientation = UIApplication.shared.statusBarOrientation
                    
                    // Update menu frames
                    setOpenClosedFrameForBarButtonFrame(statusBarOrientation: UIApplication.shared.statusBarOrientation)
                    
                    // Open Menu
                    toggleMenu()
                }
            }
        }
    }
    
    @objc public func toggleMenu() {
        isShown = !isShown
        
        if !isShown {
            animateMenuOpen(open: false, completion: { () -> Void in
                self.isHidden = true
                self.menuScrollView?.isHidden = true
            })
        } else {
            self.isHidden = false
            self.menuScrollView?.isHidden = false
            
            animateMenuOpen(open: true, completion: { () -> Void in
                self.didTapActionButton = false
            })
        }
    }
    
    private func animateMenuOpen(open: Bool, completion: (() -> Void)?) {
        var frameAnimatingTo: CGRect = CGRect.zero
        
        if open {
            frameAnimatingTo = openedFrame
        } else {
            frameAnimatingTo = closedFrame
        }
        
        // Animating with option
        switch menuAnimationOption {
        case .expand:
            menuScrollView?.alpha = 1.0
            UIView.animate(withDuration: menuAnimationDuration, animations: { () -> Void in
                self.menuScrollView?.frame = frameAnimatingTo
            }, completion: { (completed: Bool) -> Void in
                if completion != nil { completion!() }
            })
        case .fade:
            self.menuScrollView?.frame = self.openedFrame
            if isShown {
                menuScrollView?.alpha = 0.0
                menuScrollView?.layer.shadowOpacity = 0.0
            }
            UIView.animate(withDuration: menuAnimationDuration, animations: { () -> Void in
                if self.isShown { // Open
                    self.menuScrollView?.alpha = 1.0
                    if self.hasShadow { self.menuScrollView?.layer.shadowOpacity = 1.0 }
                } else { // Close
                    self.menuScrollView?.alpha = 0.0
                    if self.hasShadow { self.menuScrollView?.layer.shadowOpacity = 0.0 }
                }
            }, completion: { (completed: Bool) -> Void in
                if completion != nil { completion!() }
            })
        case .none:
            self.menuScrollView?.frame = self.openedFrame
            if isShown {
                menuScrollView?.alpha = 0.0
                menuScrollView?.layer.shadowOpacity = 0.0
            }
            if self.isShown { // Open
                self.menuScrollView?.alpha = 1.0
                if self.hasShadow { self.menuScrollView?.layer.shadowOpacity = 1.0 }
            } else { // Close
                self.menuScrollView?.alpha = 0.0
                if self.hasShadow { self.menuScrollView?.layer.shadowOpacity = 0.0 }
            }
            if completion != nil { completion!() }
        }
    }
    
    // MARK: - Action
    public func addAction(action: CAPSOptionsMenuAction) {
        actions.append(action)
        addButtonForAction(action: action)
        
        // Update frame for actions
        let actionsHeight: CGFloat = CGFloat(44 * actions.count)
        openedFrame.size.height = actionsHeight
        menuScrollView!.contentSize = CGSize(width:menuScrollView!.frame.width,height: actionsHeight)
    }
    
    private func addButtonForAction(action: CAPSOptionsMenuAction) {
        let buttonYOffset: CGFloat = CGFloat(44 * (actions.count - 1))
        let actionButtonFrame = CGRect(x: 0.0, y: buttonYOffset, width: 100.0, height: 44.0)
        let actionButton: CAPSOptionsMenuButton = CAPSOptionsMenuButton(frame: actionButtonFrame, backgroundColor: menuBackgroundColor, highlightedColor: menuActionButtonsHiglightedColor)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        actionButton.tag = actions.count - 1
        actionButton.setTitle(action.title, for: UIControl.State.normal)
        actionButton.setImage(action.image, for: .normal)
        actionButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0);
        actionButton.setTitleColor(menuActionButtonsTitleColor, for: UIControl.State.normal)
        actionButton.addTarget(self, action:#selector(buttonAction(sender:)) , for: UIControl.Event.touchUpInside)
        menuScrollView!.addSubview(actionButton)
        actionButtons.append(actionButton)
    }
    
    @objc public func buttonAction(sender: UIButton) {
        if !didTapActionButton {
            self.didTapActionButton = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.toggleMenu()
                self.actions[sender.tag].actionHandler(self.actions[sender.tag])
            }
        }
    }
    
    // MARK: - Gesture Recognizer Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == menuScrollView {
            return false
        }
        
        return true
    }
    
    // MARK: - Screen Rotation Handling in layout subviews
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if isShown {
            let orientation = UIApplication.shared.statusBarOrientation
            
            // Make sure bar button x offset is always correct depending on orientation
            let idiom = UIDevice.current.userInterfaceIdiom
            if UIInterfaceOrientation.portrait == barButtonXOrientation && UIInterfaceOrientation.landscapeRight == orientation && UIInterfaceOrientation.landscapeLeft == orientation {
                updateBarButtonXForIdiom(idiom: idiom, multiply: true)
            } else if UIInterfaceOrientation.portrait == orientation && UIInterfaceOrientation.landscapeRight == barButtonXOrientation && UIInterfaceOrientation.landscapeLeft == barButtonXOrientation {
                updateBarButtonXForIdiom(idiom: idiom, multiply: false)
            }
            barButtonXOrientation = orientation
            
            // Update menu frames
            setOpenClosedFrameForBarButtonFrame(statusBarOrientation: orientation)
        }
    }
    
    private func updateBarButtonXForIdiom(idiom: UIUserInterfaceIdiom, multiply: Bool) {
        // Static multipliers needed because barButton viw is not easily accessible
        var multiplier : CGFloat = 1.89 // 16:9
        
        if idiom == UIUserInterfaceIdiom.pad {
            multiplier = 1.357 // 4:3
        }
        
        barButtonX = multiply ? round(barButtonX * multiplier) : round(barButtonX / multiplier)
    }
}

